-- ytq.lua: YouTube queue for mpv that resolves tracks ahead of time.
-- YouTube needs ~8s to resolve a track, so keep mpv's own playlist at current + 2 direct URLs.
-- Clients (the ytrail TUI, the statusline) talk to mpv over its IPC socket:
--   script-message ytq-load <json [{title,url},...]> [start-index]   replace the queue and start
--   script-message ytq-clear                                         drop the queue
-- Published for clients: user-data/ytq/queue, user-data/ytq/idx (1-based queue index), user-data/ytq/loading
local utils = require("mp.utils")

local cookies = mp.get_opt("ytq-cookies")
local AHEAD = 2

local queue, map = {}, {}
local nextq, gen, pump_gen = 1, 0, -1

local function publish()
  local pos = mp.get_property_number("playlist-pos", -1)
  local qi = map[pos + 1] or 0
  mp.set_property_native("user-data/ytq/idx", qi)
  mp.set_property_native("user-data/ytq/loading", #queue > 0 and mp.get_property_number("time-pos", 0) == 0 and #map <= 1)
end

local function resolve(page, cb)
  local function try(extra, fallback)
    local args = { "yt-dlp" }
    for _, a in ipairs(extra) do args[#args + 1] = a end
    for _, a in ipairs({ "-f", "bestaudio", "-g", "--no-playlist", "--quiet", "--no-warnings", page }) do args[#args + 1] = a end
    mp.command_native_async({ name = "subprocess", args = args, capture_stdout = true, playback_only = false }, function(ok, res)
      local url = ok and res and res.status == 0 and res.stdout:match("[^\r\n]+") or nil
      if url then cb(url) elseif fallback then fallback() else cb(nil) end
    end)
  end
  local with_cookies = function()
    if cookies and cookies ~= "" then try({ "--cookies-from-browser", cookies }, nil) else cb(nil) end
  end
  try({}, with_cookies)
end

local function pump()
  local g = gen
  if pump_gen == g or nextq > #queue then return end
  local first = #map == 0
  local pos = math.max(mp.get_property_number("playlist-pos", 0), 0)
  if not first and (#map - 1 - pos) >= AHEAD then return end
  pump_gen = g
  local qi = nextq
  nextq = nextq + 1
  resolve(queue[qi].url, function(url)
    if g ~= gen then return end
    pump_gen = -1
    if url then
      mp.command_native({
        name = "loadfile", url = url, index = -1,
        flags = first and "replace" or (mp.get_property_bool("idle-active") and "append-play" or "append"),
        options = { ["force-media-title"] = queue[qi].title },
      })
      map[#map + 1] = qi
      if first then mp.set_property_bool("pause", false) end
      publish()
    end
    pump()
  end)
end

local function reset(entries, start)
  gen = gen + 1
  pump_gen = -1
  queue = entries or {}
  map = {}
  nextq = start or 1
  mp.set_property_native("user-data/ytq/queue", queue)
  publish()
end

mp.register_script_message("ytq-load", function(json, start)
  local entries = utils.parse_json(json)
  if type(entries) ~= "table" then return end
  reset(entries, tonumber(start) or 1)
  mp.set_property_native("user-data/ytq/loading", true)
  pump()
end)

-- Add tracks to the end of the queue without touching what is playing.
mp.register_script_message("ytq-append", function(json)
  local entries = utils.parse_json(json)
  if type(entries) ~= "table" then return end
  for _, e in ipairs(entries) do queue[#queue + 1] = e end
  mp.set_property_native("user-data/ytq/queue", queue)
  pump()
end)

mp.register_script_message("ytq-clear", function()
  reset({}, 1)
  mp.commandv("stop")
end)

mp.observe_property("playlist-pos", "number", function()
  publish()
  pump()
end)
mp.observe_property("time-pos", "number", function(_, v)
  if v and v > 0 then mp.set_property_native("user-data/ytq/loading", false) end
end)
