#!/usr/bin/env node
// Standalone Claude rail: the same panels as nvim's claude_rail.lua, drawn in its own terminal pane.
// Reads the state written by ~/.claude/hooks/claude-state.sh and ~/.claude/statusline.sh; no dependencies.
// Click a header (or press 1-8) to fold a section, q to quit.
import { readFileSync, readdirSync, watch, mkdirSync, existsSync } from "node:fs";
import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { basename, join } from "node:path";

const DIR = join(process.env.XDG_STATE_HOME || join(homedir(), ".local/state"), "claude-state");
const SPIN = [..."⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"];
const tick = () => Math.floor(Date.now() / 150);

// Tokyo Night, like the rest of the setup.
const C = { text: [192, 202, 245], muted: [86, 95, 137], accent: [224, 175, 104], ok: [158, 206, 106], work: [224, 175, 104], wait: [247, 118, 142], branch: [187, 154, 247] };
const fg = ([r, g, b]) => `\x1b[38;2;${r};${g};${b}m`;
const RESET = "\x1b[0m";
const col = (name) => fg(C[name] || C.text);

const S = { sess: null, git: { branch: "", list: [], add: 0, del: 0 }, flow: { branches: [], prs: [] }, music: null, fold: new Set(), hdr: {} };

const run = (cmd, args, cb, cwd) =>
  execFile(cmd, args, { cwd, timeout: 15000 }, (err, out) => cb(err ? "" : String(out)));

const gitRoot = (dir) => {
  for (let d = dir; d !== "/"; d = join(d, "..")) if (existsSync(join(d, ".git"))) return d;
  return dir;
};
const ROOT = gitRoot(process.cwd());

const readJson = (p) => { try { return JSON.parse(readFileSync(p, "utf8")); } catch { return null; } };

function loadSession() {
  let best = null;
  try {
    for (const name of readdirSync(DIR)) {
      if (!name.endsWith(".json") || name.endsWith(".status.json")) continue;
      const d = readJson(join(DIR, name));
      if (!d?.cwd || !(d.cwd === ROOT || d.cwd.startsWith(ROOT + "/"))) continue;
      if (Date.now() / 1000 - (d.ts || 0) > 43200) continue;
      if (!best || d.ts > best.ts) best = d;
    }
  } catch {}
  if (best) best.status = readJson(join(DIR, `${best.session}.status.json`)) || {};
  S.sess = best;
}

function loadGit() {
  run("git", ["-C", ROOT, "status", "--porcelain=v1", "-b"], (out) => {
    const lines = out.split("\n").filter(Boolean);
    S.git.branch = (lines[0] || "").replace(/^## /, "").replace(/\.\.\..*$/, "");
    S.git.list = lines.slice(1).map((l) => ({ st: l.slice(0, 2).trim(), path: l.slice(3) }));
  });
  run("git", ["-C", ROOT, "diff", "--shortstat", "HEAD"], (out) => {
    S.git.add = +(out.match(/(\d+) insertion/)?.[1] || 0);
    S.git.del = +(out.match(/(\d+) deletion/)?.[1] || 0);
  });
}

function loadFlow() {
  run("git", ["-C", ROOT, "for-each-ref", "--sort=-committerdate", "--count=5", "--format=%(HEAD)|%(refname:short)|%(upstream:track)", "refs/heads"], (out) => {
    S.flow.branches = out.split("\n").filter(Boolean).map((l) => {
      const [head, name, track = ""] = l.split("|");
      return { cur: head === "*", name, ahead: +(track.match(/ahead (\d+)/)?.[1] || 0), behind: +(track.match(/behind (\d+)/)?.[1] || 0) };
    });
  });
  run("gh", ["pr", "list", "--state", "open", "--limit", "5", "--json", "number,title,isDraft,statusCheckRollup"], (out) => {
    try {
      S.flow.prs = JSON.parse(out).map((pr) => {
        let ci = "ok";
        for (const c of pr.statusCheckRollup || []) {
          if (["FAILURE", "TIMED_OUT"].includes(c.conclusion) || c.state === "FAILURE") { ci = "fail"; break; }
          if ((c.status && c.status !== "COMPLETED") || c.state === "PENDING") ci = "wait";
        }
        return { ...pr, ci: pr.statusCheckRollup?.length ? ci : "none" };
      });
    } catch {}
  }, ROOT);
}

function loadMusic() {
  run("gentle-stream", ["ctl", "status"], (out) => { try { S.music = JSON.parse(out); } catch { S.music = null; } });
}

const gauge = (pct, cells) => { const f = Math.round((pct * cells) / 100); return "▰".repeat(f) + "▱".repeat(cells - f); };
const level = (pct, warn = 80, err = 95) => (pct >= err ? "wait" : pct >= warn ? "work" : "ok");
const len = (s) => [...s].length;
const trunc = (s, n) => (len(s) > n ? [...s].slice(0, Math.max(n - 1, 0)).join("") + "…" : s);

// A row is a list of [text, color] chunks.
function panel(id, title, count, tone, body, W) {
  const open = !S.fold.has(id);
  const head = (open ? "▾ " : "▸ ") + title;
  const rows = [{ id, chunks: [[head, "accent"]] }];
  if (count) {
    const c = trunc(count, Math.max(W - 1 - len(head) - 2, 1));
    rows[0].chunks.push([" ".repeat(Math.max(W - 1 - len(head) - len(c), 1)), "text"], [c, tone]);
  }
  if (open) for (const r of body) rows.push({ chunks: [["  ", "text"], ...r] });
  rows.push({ chunks: [] });
  return rows;
}
const kv = (k, v, c = "text") => [[k.padEnd(8), "muted"], [v, c]];

function build(W) {
  const s = S.sess, st = s?.status || {}, inner = W - 4, rows = [];
  let tone = "muted", label = "no session";
  if (s) {
    if (s.state === "working") { tone = "work"; label = `${SPIN[tick() % SPIN.length]} working${s.tool ? " · " + s.tool : ""}`; }
    else if (s.state === "waiting") { tone = "wait"; label = "waiting for you"; }
    else { tone = "ok"; label = "idle"; }
  }
  const status = [kv("Project", trunc(basename(ROOT), inner - 8)), kv("Branch", trunc(S.git.branch || "-", inner - 8), "branch"), kv("Model", st.model || "-")];
  if (st.ctx != null) status.push([["Context ".padEnd(8), "muted"], [gauge(st.ctx, 8), level(st.ctx, 50, 80)], [` ${Math.round(st.ctx)}%`, "muted"]]);
  rows.push(...panel("status", "Status", label, tone, status, W));

  const g = S.git, cb = [];
  g.list.slice(0, 6).forEach((f) => cb.push([[f.st.padEnd(3), /[DU]/.test(f.st) ? "wait" : /[?A]/.test(f.st) ? "ok" : "work"], [trunc(basename(f.path), inner - 4), "text"]]));
  if (g.list.length > 6) cb.push([[`+${g.list.length - 6} more`, "muted"]]);
  if (!cb.length) cb.push([["clean", "muted"]]);
  rows.push(...panel("changes", "Changes", g.list.length ? `${g.list.length} · +${g.add} -${g.del}` : "", "accent", cb, W));

  const todos = s?.todos || [];
  if (todos.length) {
    const done = todos.filter((t) => t.status === "completed").length;
    rows.push(...panel("todos", "Todos", `${done}/${todos.length}`, "accent", todos.map((t) => {
      const [icon, c] = t.status === "completed" ? ["✓", "muted"] : t.status === "in_progress" ? ["●", "work"] : ["○", "text"];
      return [[icon + " ", c], [trunc(t.content || "", inner - 2), c]];
    }), W));
  }
  const agents = s?.agents || [];
  if (agents.length) rows.push(...panel("agents", "Agents", `${agents.length} running`, "work",
    agents.map((a, i) => [[SPIN[(tick() + i) % SPIN.length] + " ", "work"], [trunc(`${a.kind} · ${a.desc || "working"}`, inner - 2), "text"]]), W));
  const jobs = s?.jobs || [];
  if (jobs.length) rows.push(...panel("jobs", "Jobs", `${jobs.length} background`, "accent", jobs.map((j) => [["▸ ", "work"], [trunc(j.cmd, inner - 2), "text"]]), W));

  if (st.r5 != null || st.r7 != null || st.cost != null || st.added != null) {
    const ub = [];
    for (const [l, p] of [["5h", st.r5], ["7d", st.r7]]) if (p != null) ub.push([[l.padEnd(4), "muted"], [gauge(p, 8), level(p)], [` ${Math.round(p)}%`, "muted"]]);
    if (st.cost != null) ub.push(kv("Cost", `$${st.cost.toFixed(2)}`));
    if (st.added != null || st.removed != null) ub.push([["Lines".padEnd(8), "muted"], [`+${st.added || 0}`, "ok"], [` -${st.removed || 0}`, "wait"]]);
    rows.push(...panel("usage", "Usage", st.r5 != null ? `5h ${Math.round(st.r5)}%` : "", "accent", ub, W));
  }

  const fl = S.flow;
  if (fl.branches.length || fl.prs.length) {
    const gb = fl.branches.map((b) => [[b.cur ? "● " : "  ", "branch"], [trunc(b.name, inner - 6), b.cur ? "text" : "muted"], [(b.ahead ? ` ↑${b.ahead}` : "") + (b.behind ? ` ↓${b.behind}` : ""), "work"]]);
    for (const pr of fl.prs) {
      const [icon, c] = { ok: ["✓", "ok"], fail: ["✗", "wait"], wait: ["…", "work"] }[pr.ci] || ["●", "muted"];
      gb.push([[icon + " ", c], [`#${pr.number} `, "accent"], [trunc(pr.title, inner - 8), pr.isDraft ? "muted" : "text"]]);
    }
    rows.push(...panel("git", "Git", fl.prs.length ? `${fl.prs.length} PR${fl.prs.length === 1 ? "" : "s"}` : "branches", "branch", gb, W));
  }

  const m = S.music, playing = m?.running && m?.playing;
  const mb = m?.running ? [[["♪ ", playing ? "ok" : "muted"], [trunc(m.name || "?", inner - 2), "text"]], [[trunc(m.genre || "", inner), "muted"]]] : [[["nothing is playing", "muted"]]];
  rows.push(...panel("music", "Music", m?.running ? (playing ? "playing" : "paused") : "", playing ? "ok" : "muted", mb, W));
  return rows;
}

const ORDER = ["status", "changes", "todos", "agents", "jobs", "usage", "git", "music"];

function draw() {
  const W = process.stdout.columns || 30, H = process.stdout.rows || 40;
  const rows = build(W);
  S.hdr = {};
  let out = "\x1b[H";
  rows.slice(0, H).forEach((r, i) => {
    if (r.id) S.hdr[i + 1] = r.id;
    out += r.chunks.map(([t, c]) => col(c) + t).join("") + RESET + "\x1b[K\r\n";
  });
  out += "\x1b[J";
  process.stdout.write(out.replace(/\r\n$/, ""));
}

const toggle = (id) => { if (id) { S.fold.has(id) ? S.fold.delete(id) : S.fold.add(id); draw(); } };

function main() {
  mkdirSync(DIR, { recursive: true });
  process.stdout.write("\x1b[?1049h\x1b[?25l\x1b[?1000h\x1b[?1006h");
  const quit = () => { process.stdout.write("\x1b[?1006l\x1b[?1000l\x1b[?25h\x1b[?1049l"); process.exit(0); };
  process.on("SIGINT", quit); process.on("SIGTERM", quit);
  process.stdout.on("resize", draw);
  if (process.stdin.isTTY) {
    process.stdin.setRawMode(true);
    process.stdin.on("data", (b) => {
      const k = String(b);
      const m = k.match(/\x1b\[<(\d+);(\d+);(\d+)M/);
      if (m && m[1] === "0") return toggle(S.hdr[+m[3]]);
      if (k === "q" || k === "\x03") quit();
      if (/^[1-8]$/.test(k)) toggle(ORDER[+k - 1]);
    });
  }
  loadSession(); loadGit(); loadFlow(); loadMusic(); draw();
  try { watch(DIR, () => { loadSession(); draw(); }); } catch {}
  setInterval(() => { const s = S.sess; if (s && (s.state === "working" || (s.agents || []).length)) draw(); }, 150);
  setInterval(() => { loadGit(); loadSession(); draw(); }, 4000);
  setInterval(() => { loadMusic(); }, 4000);
  setInterval(loadFlow, 45000);
}
main();
