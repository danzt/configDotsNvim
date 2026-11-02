#!/usr/bin/env node
// ytrail: YouTube Music panel for the terminal. A thin client over the mpv started with ytq.lua
// (which resolves tracks ahead of time), so music keeps playing when this panel closes.
//   Home menu → Search / Liked / Playlists. Search shows results to pick from.
//   Works on small screens: album art only when there is room (and never inside nvim).
import { execFile, spawn } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { connect } from "node:net";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";

const HOME = homedir();
const DIR = process.env.YTRAIL_DIR ?? join(HOME, ".local/state/ytrail");
const SOCK = join(DIR, "mpv.sock");
const LUA = join(HOME, ".local/share/ytrail/ytq.lua");
const COOKIES = `firefox:${join(HOME, "Library/Application Support/zen/Profiles/eicbco45.Default (release)")}`;
const LIKED = "https://www.youtube.com/playlist?list=LM";
const MAX_QUEUE = 200;
const IMG_ID = 7;
const ART_COLS = 20;

const out = (s) => process.stdout.write(s);
const rgb = (r, g, b) => (s) => `\x1b[38;2;${r};${g};${b}m${s}\x1b[0m`;
const accent = rgb(111, 160, 175);
const muted = rgb(138, 143, 152);
const dim = rgb(92, 97, 112);
const green = rgb(183, 204, 133);
const bold = (s) => `\x1b[1m${s}\x1b[0m`;
const rev = (s) => `\x1b[7m${s}\x1b[0m`;

const S = {
  title: "", artist: "", pos: 0, dur: 0, paused: false, volume: Number(process.env.YTRAIL_VOLUME ?? 35),
  idx: 0, queue: [], loading: false, idle: true, cursor: 1,
  mode: "home", // home | main | list | search
  list: { kind: "", title: "", items: [], sel: 0 },
  input: "", status: "",
};
let sock, buf = "", artFor, artShown;

// ---------- helpers ----------

const run = (cmd, args) =>
  new Promise((res, rej) => execFile(cmd, args, { maxBuffer: 32 << 20 }, (e, o) => (e ? rej(e) : res(o))));
const clock = (s) => {
  if (!Number.isFinite(s) || s < 0) return "0:00";
  const t = Math.floor(s), h = Math.floor(t / 3600), m = Math.floor((t % 3600) / 60), sec = String(t % 60).padStart(2, "0");
  return h ? `${h}:${String(m).padStart(2, "0")}:${sec}` : `${m}:${sec}`;
};
const fit = (s, n) => { const a = [...String(s)]; return a.length > n ? a.slice(0, Math.max(0, n - 1)).join("") + "…" : a.join(""); };
const videoId = (u) => /(?:[?&]v=|youtu\.be\/)([\w-]{11})/.exec(u ?? "")?.[1];
const clean = (v) => (v && v !== "NA" ? v : "");

// ---------- mpv ----------

function send(command) { sock?.write(`${JSON.stringify({ command })}\n`); }

async function tryConnect() {
  if (!existsSync(SOCK)) return false;
  return new Promise((resolve) => {
    const s = connect(SOCK);
    s.once("error", () => resolve(false));
    s.once("connect", () => { sock = s; resolve(true); });
  });
}

async function connectMpv() {
  if (await tryConnect()) return;
  mkdirSync(DIR, { recursive: true });
  rmSync(SOCK, { force: true });
  spawn("mpv", [
    "--no-video", "--idle=yes", "--no-terminal", "--force-window=no", `--volume=${S.volume}`,
    `--input-ipc-server=${SOCK}`, `--script=${LUA}`, `--script-opts=ytq-cookies=${COOKIES}`,
    `--ytdl-raw-options=cookies-from-browser=${COOKIES}`,
    ...(process.env.YTRAIL_LOG ? [`--log-file=${process.env.YTRAIL_LOG}`, "--msg-level=all=v"] : []),
  ], { detached: true, stdio: "ignore" }).unref();
  for (let i = 0; i < 40; i++) {
    await new Promise((r) => setTimeout(r, 150));
    if (await tryConnect()) return;
  }
  throw new Error("mpv did not start (is it installed?)");
}

function observe() {
  const props = ["media-title", "time-pos", "duration", "pause", "volume", "metadata",
    "user-data/ytq/queue", "user-data/ytq/idx", "user-data/ytq/loading", "idle-active"];
  props.forEach((p, i) => send(["observe_property", i + 1, p]));
  sock.on("data", (d) => {
    buf += d.toString();
    let nl;
    while ((nl = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, nl); buf = buf.slice(nl + 1);
      try {
        const m = JSON.parse(line);
        if (m.event === "property-change") apply(m.name, m.data);
      } catch { /* ignore */ }
    }
  });
  sock.on("close", () => { S.status = "mpv closed"; draw(); });
}

function apply(name, v) {
  if (name === "media-title") S.title = v ?? "";
  else if (name === "time-pos") S.pos = Number(v ?? 0);
  else if (name === "duration") S.dur = Number(v ?? 0);
  else if (name === "pause") S.paused = v === true;
  else if (name === "volume") S.volume = Math.round(Number(v ?? S.volume));
  else if (name === "metadata") S.artist = v?.artist ?? v?.ARTIST ?? v?.uploader ?? "";
  else if (name === "user-data/ytq/queue") S.queue = Array.isArray(v) ? v : [];
  else if (name === "user-data/ytq/idx") {
    const follow = S.cursor === 1 || S.cursor === S.idx + 1;
    S.idx = Number(v ?? 0);
    if (follow) S.cursor = Math.max(1, S.idx + 1);
  } else if (name === "user-data/ytq/loading") S.loading = v === true;
  else if (name === "idle-active") S.idle = v === true;
  throttledDraw();
}

// ---------- sources ----------

async function flat(source) {
  const raw = await run("yt-dlp", ["--cookies-from-browser", COOKIES, "--quiet", "--no-warnings", "--flat-playlist",
    "--playlist-end", String(MAX_QUEUE), "--print", "%(title)s\t%(url)s\t%(channel)s\t%(duration_string)s", source]);
  return raw.split("\n").map((l) => l.split("\t")).filter((p) => p[0] && p[1])
    .map(([title, url, channel, dur]) => ({ title, url, sub: clean(channel), dur: clean(dur) }));
}

const asEntries = (items) => items.map(({ title, url }) => ({ title, url }));

function showList(kind, title, items) {
  S.list = { kind, title, items, sel: 0 };
  S.mode = "list";
  S.status = "";
  draw();
}

async function playSource(source) {
  S.status = "loading…"; draw();
  try {
    const entries = await flat(source);
    if (!entries.length) { S.status = "nothing found (logged in to YouTube in Zen?)"; return draw(); }
    send(["script-message", "ytq-load", JSON.stringify(asEntries(entries)), "1"]);
    S.mode = "main"; S.cursor = 1; S.status = "";
  } catch (e) { S.status = `error: ${e.message.split("\n")[0]}`; }
  draw();
}

async function search(q) {
  S.status = `searching “${q}”…`; draw();
  try {
    const items = await flat(`ytsearch20:${q}`);
    if (!items.length) { S.status = "no results"; return draw(); }
    showList("results", `Results for “${q}”`, items);
  } catch (e) { S.status = `error: ${e.message.split("\n")[0]}`; draw(); }
}

async function openPlaylists() {
  S.status = "loading playlists…"; draw();
  let items = [{ title: "♥ Liked songs", url: LIKED, sub: "", dur: "" }];
  try { items = items.concat(await flat("https://www.youtube.com/feed/playlists")); } catch { /* liked only */ }
  showList("playlists", "Your playlists", items);
}

function goHome() {
  const items = [
    { title: "Search songs", sub: "type a name, then pick from the results", act: () => beginSearch() },
    { title: "♥ Liked songs", sub: "your YouTube Music likes", act: () => playSource(LIKED) },
    { title: "Your playlists", sub: "choose one to play", act: () => openPlaylists() },
  ];
  if (S.queue.length) items.push({ title: "Now playing", sub: `${S.queue.length} tracks in the queue`, act: () => { S.mode = "main"; draw(); } });
  S.list = { kind: "home", title: "What do you want to listen to?", items, sel: 0 };
  S.mode = "list";
  draw();
}

function beginSearch() { S.mode = "search"; S.input = ""; draw(); }

// ---------- album art (Kitty graphics) ----------

const art = new Map();
async function thumb(id) {
  if (art.has(id)) return art.get(id);
  try {
    const r = await fetch(`https://i.ytimg.com/vi/${id}/mqdefault.jpg`);
    if (!r.ok) return undefined;
    const base = join(tmpdir(), `ytrail-${process.getuid?.() ?? 0}-${id}`);
    writeFileSync(`${base}.jpg`, Buffer.from(await r.arrayBuffer()));
    await run("sips", ["-Z", "240", "-s", "format", "png", `${base}.jpg`, "--out", `${base}.png`]);
    const b64 = readFileSync(`${base}.png`).toString("base64");
    rmSync(`${base}.jpg`, { force: true }); rmSync(`${base}.png`, { force: true });
    art.set(id, b64);
    return b64;
  } catch { return undefined; }
}

// Art needs room, a terminal that draws Kitty images (not nvim's :terminal) and the now-playing screen.
const artOk = () => S.mode === "main" && !process.env.NVIM && process.stdout.columns >= 72 && process.stdout.rows >= 20;

function clearArt() { if (process.env.NVIM) return; out(`\x1b_Ga=d,d=i,i=${IMG_ID},q=2\x1b\\`); artShown = undefined; }

function placeArt(b64) {
  out("\x1b7\x1b[3;2H");
  for (let i = 0; i < b64.length; i += 4096) {
    const chunk = b64.slice(i, i + 4096), more = i + 4096 < b64.length ? 1 : 0;
    out(`\x1b_G${i === 0 ? `a=T,f=100,q=2,C=1,c=${ART_COLS},i=${IMG_ID},` : ""}m=${more};${chunk}\x1b\\`);
  }
  out("\x1b8");
}

async function syncArt() {
  if (!artOk()) { if (artShown) clearArt(); artFor = undefined; return; }
  const id = videoId(S.queue[S.idx - 1]?.url);
  if (id === artFor) return;
  artFor = id;
  clearArt();
  if (!id) return;
  const b64 = await thumb(id);
  if (b64 && id === artFor && artOk()) { placeArt(b64); artShown = id; }
}

// ---------- drawing ----------

let timer;
function throttledDraw() { if (!timer) timer = setTimeout(() => { timer = undefined; draw(); }, 200); }

function footer() {
  if (S.mode === "search") return `${accent("search:")} ${S.input}█   ${dim("enter find · esc cancel")}`;
  if (S.status) return accent(S.status);
  if (S.idle && S.queue.length > 0 && !S.loading && S.mode === "main") return accent("YouTube blocked the stream (403). Turn off your VPN and press enter on a track.");
  if (S.mode === "list") {
    const k = S.list.kind;
    if (k === "results") return dim("enter play · a add to queue · / new search · esc menu");
    if (k === "home") return dim("j/k move · enter select · / search · q close");
    return dim("j/k move · enter play · esc menu");
  }
  return dim("space ▶/❚❚ · n/p track · +/- vol · / search · h menu · q close · Q stop");
}

function draw() {
  const W = process.stdout.columns, H = process.stdout.rows;
  const rows = new Map(); // row -> [[col, text]]
  const put = (row, col, text) => { if (row < 1 || row > H) return; (rows.get(row) ?? rows.set(row, []).get(row)).push([col, text]); };
  // idle with a queue means mpv gave up on every track (YouTube answered 403: often a VPN/datacenter IP).
  const failed = S.idle && S.queue.length > 0 && !S.loading;
  const state = S.loading ? "resolving…" : failed ? "can't play" : S.paused ? "paused" : S.idle ? "idle" : "playing";
  put(1, 1, ` ${accent("♪ YT Music")} ${muted("· " + state)}${S.title && S.mode !== "main" ? muted("  " + fit(S.title, Math.max(8, W - 30))) : ""}`);

  const body = H - 3;
  let artRows = 0, infoCol = 2;

  if (S.mode === "main") {
    const wide = artOk() || (!process.env.NVIM && W >= 72 && H >= 20);
    if (wide) { artRows = 7; infoCol = ART_COLS + 4; }
    const infoW = Math.max(10, W - infoCol - 1);
    if (wide) {
      put(3, infoCol, bold(accent(fit(S.title || "nothing playing", infoW))));
      put(4, infoCol, muted(fit(S.artist, infoW)));
      put(6, infoCol, `${clock(S.pos)} / ${clock(S.dur)}`);
      put(7, infoCol, dim(`vol ${S.volume}%`));
    } else {
      put(3, 2, bold(accent(fit(S.title || "nothing playing", W - 3))));
      put(4, 2, muted(fit(`${S.artist}${S.artist ? " · " : ""}${clock(S.pos)} / ${clock(S.dur)} · vol ${S.volume}%`, W - 3)));
    }
    const top = wide ? 10 : 6;
    const barW = Math.max(4, W - 4);
    const ratio = S.dur > 0 ? Math.min(1, S.pos / S.dur) : 0, filled = Math.round(barW * ratio);
    put(top, 2, accent("━".repeat(filled)) + dim("─".repeat(barW - filled)));
    const first = top + 2, last = H - 2, n = Math.max(0, last - first + 1);
    put(first - 1, 2, dim(`queue · ${S.queue.length} tracks`));
    const start = Math.max(0, Math.min(S.cursor - 1 - Math.floor(n / 2), S.queue.length - n));
    S.queue.slice(start, start + n).forEach((t, i) => {
      const num = start + i + 1, cur = num === S.idx, sel = num === S.cursor;
      const txt = fit(`${String(num).padStart(2)}. ${t.title}`, W - 6);
      put(first + i, 2, `${cur ? green("▶") : " "} ${sel ? rev(txt) : cur ? green(txt) : muted(txt)}`);
    });
  } else if (S.mode === "list" || S.mode === "search") {
    const L = S.list;
    put(3, 2, bold(accent(fit(L.title, W - 3))));
    const per = L.kind === "home" ? 2 : 1; // home items get a description line
    const n = Math.max(1, Math.floor((H - 6) / per));
    const start = Math.max(0, Math.min(L.sel - Math.floor(n / 2), L.items.length - n));
    L.items.slice(start, start + n).forEach((it, i) => {
      const row = 5 + i * per, sel = start + i === L.sel;
      if (L.kind === "home") {
        put(row, 2, sel ? rev(` ${fit(it.title, W - 6)} `) : ` ${bold(it.title)}`);
        put(row + 1, 4, dim(fit(it.sub, W - 6)));
      } else {
        const tail = [it.sub, it.dur].filter(Boolean).join(" · ");
        const room = W - 6, left = fit(it.title, tail ? Math.max(10, room - tail.length - 3) : room);
        put(row, 2, sel ? rev(` ${left}${tail ? "  " + tail : ""} `) : ` ${muted(left)}${tail ? "  " + dim(tail) : ""}`);
      }
    });
  }
  put(H, 2, footer());

  let frame = "";
  for (let r = 1; r <= H; r++) {
    const cells = rows.get(r) ?? [];
    const beside = r >= 3 && r < 3 + artRows; // keep the Kitty image intact
    frame += `\x1b[${r};1H`;
    if (!beside) frame += "\x1b[2K";
    else frame += `\x1b[${infoCol};1H`.replace(";1H", `;${infoCol}H`) + "\x1b[K";
    for (const [col, text] of cells) frame += `\x1b[${r};${col}H${text}`;
  }
  out(frame);
  void syncArt();
}

// ---------- input ----------

function moveSel(d) { const L = S.list; L.sel = Math.max(0, Math.min(L.items.length - 1, L.sel + d)); }

function key(k) {
  if (S.mode === "search") {
    if (k === "\r") { const q = S.input.trim(); S.input = ""; if (q) { S.mode = "list"; void search(q); } else goHome(); return; }
    else if (k === "\x1b" || k === "\x03") { S.input = ""; return goHome(); }
    else if (k === "\x7f") S.input = S.input.slice(0, -1);
    else if (k >= " " && !k.startsWith("\x1b")) S.input += k;
    return draw();
  }
  if (S.mode === "list") {
    const L = S.list, it = L.items[L.sel];
    if (k === "j" || k === "\x1b[B") moveSel(1);
    else if (k === "k" || k === "\x1b[A") moveSel(-1);
    else if (k === "/") return beginSearch();
    else if (k === "\x1b" || k === "h") return L.kind === "home" ? (S.queue.length ? (S.mode = "main", draw()) : draw()) : goHome();
    else if (k === "q" || k === "\x03") return quit(false);
    else if (k === "a" && L.kind === "results" && it) { send(["script-message", "ytq-append", JSON.stringify(asEntries([it]))]); S.status = `added: ${fit(it.title, 40)}`; setTimeout(() => { S.status = ""; draw(); }, 1800); }
    else if (k === "\r" && it) {
      if (L.kind === "home") return it.act();
      if (L.kind === "results") { send(["script-message", "ytq-load", JSON.stringify(asEntries(L.items.slice(L.sel))), "1"]); S.mode = "main"; S.cursor = 1; }
      else { S.mode = "main"; void playSource(it.url); }
    }
    return draw();
  }
  switch (k) {
    case " ": send(["cycle", "pause"]); break;
    case "n": send(["playlist-next"]); break;
    case "p": send(["playlist-prev"]); break;
    case "+": case "=": send(["add", "volume", 5]); break;
    case "-": send(["add", "volume", -5]); break;
    case "j": case "\x1b[B": S.cursor = Math.min(S.queue.length, S.cursor + 1); break;
    case "k": case "\x1b[A": S.cursor = Math.max(1, S.cursor - 1); break;
    case "\r": if (S.queue.length) send(["script-message", "ytq-load", JSON.stringify(S.queue), String(S.cursor)]); break;
    case "/": return beginSearch();
    case "h": case "\x1b": return goHome();
    case "l": void playSource(LIKED); break;
    case "P": void openPlaylists(); break;
    case "s": send(["script-message", "ytq-clear"]); break;
    case "q": case "\x03": return quit(false);
    case "Q": return quit(true);
  }
  draw();
}

function quit(stop) {
  if (stop) { send(["script-message", "ytq-clear"]); send(["quit"]); }
  clearArt();
  out("\x1b[?25h\x1b[?1049l");
  process.stdin.setRawMode?.(false);
  setTimeout(() => process.exit(0), 50);
}

// ---------- main ----------

(async () => {
  if (!process.stdout.isTTY) { console.error("ytrail needs a terminal"); process.exit(1); }
  try { await connectMpv(); } catch (e) { console.error(e.message); process.exit(1); }
  out("\x1b[?1049h\x1b[?25l");
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.on("data", (d) => key(d.toString()));
  process.stdout.on("resize", () => { artFor = undefined; clearArt(); draw(); });
  observe();
  draw();
  // Land on the now-playing screen if music is already going, otherwise on the menu.
  setTimeout(() => { if (S.queue.length) { S.mode = "main"; draw(); } else goHome(); }, 500);
  setInterval(draw, 1000);
})();
