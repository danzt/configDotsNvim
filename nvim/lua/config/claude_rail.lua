-- Gentle-Shell-style header + rail for Claude Code, driven by live state from
--   ~/.claude/hooks/claude-state.sh (hooks: working/tool/post/waiting/idle) and ~/.claude/statusline.sh (model/ctx/cost).
-- The header is a winbar on the Claude terminal window; the rail is a floating card (<leader>aR).
local M = {}

local uv = vim.uv or vim.loop
local DIR = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")) .. "/claude-state"
local WIDTH = 36
local SPIN = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local S = { sess = nil, git = { branch = "", files = 0, add = 0, del = 0, list = {} }, win = nil, buf = nil, auto = true }

-- Colors come from the active colorscheme; every group carries the panel background so the
-- header and rail read as solid blocks (Gentle Shell "float" style).
local function highlights()
  local function get(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end
  local bg = get("NormalFloat").bg or get("Normal").bg
  local text = get("Normal").fg
  local specs = {
    RailWork = "DiagnosticWarn", RailOk = "DiagnosticOk", RailWait = "DiagnosticError",
    RailAccent = "Title", RailMuted = "Comment", RailBranch = "Special", RailText = "Normal",
  }
  for name, from in pairs(specs) do
    vim.api.nvim_set_hl(0, name, { fg = get(from).fg or text, bg = bg, bold = name == "RailAccent" or nil })
  end
  vim.api.nvim_set_hl(0, "RailPanel", { fg = text, bg = bg })
end

-- Project of the Claude terminal (its cwd is in the buffer name: term://<cwd>//<pid>:<cmd>), which can
-- differ from nvim's own cwd; falls back to nvim's cwd when there is no Claude terminal.
local function root()
  local cwd = uv.cwd()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    local name = vim.api.nvim_buf_get_name(b)
    if vim.bo[b].buftype == "terminal" and name:match("claude") then
      local dir = name:match("^term://(.-)//%d+:")
      if dir then cwd = vim.fn.expand(dir) break end
    end
  end
  return vim.fs.root(cwd, ".git") or cwd
end

local function readjson(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local ok, d = pcall(vim.json.decode, f:read("*a"))
  f:close()
  return ok and d or nil
end

--- Newest live session whose cwd is inside this project.
local function load_session()
  local r, best = root(), nil
  for name in vim.fs.dir(DIR) do
    if name:match("%.json$") and not name:match("%.status%.json$") then
      local d = readjson(DIR .. "/" .. name)
      if d and d.cwd and (d.cwd == r or vim.startswith(d.cwd, r .. "/")) and os.time() - (d.ts or 0) < 43200
        and (not best or d.ts > best.ts) then
        best = d
      end
    end
  end
  if best then best.status = readjson(DIR .. "/" .. best.session .. ".status.json") or {} end
  S.sess = best
end

local function load_git()
  local r = root()
  vim.system({ "git", "-C", r, "status", "--porcelain=v1", "-b" }, { text = true }, function(o)
    local lines = vim.split(o.stdout or "", "\n", { trimempty = true })
    local head = (lines[1] or ""):gsub("^## ", ""):gsub("%.%.%..*$", "")
    local list = {}
    for i = 2, #lines do list[#list + 1] = { st = vim.trim(lines[i]:sub(1, 2)), path = lines[i]:sub(4) } end
    vim.schedule(function() S.git.branch, S.git.files, S.git.list = head, #list, list end)
  end)
  vim.system({ "git", "-C", r, "diff", "--shortstat", "HEAD" }, { text = true }, function(o)
    local out = o.stdout or ""
    vim.schedule(function()
      S.git.add = tonumber(out:match("(%d+) insertion")) or 0
      S.git.del = tonumber(out:match("(%d+) deletion")) or 0
    end)
  end)
end

local function gauge(pct, cells)
  local filled = math.floor(pct * cells / 100 + 0.5)
  return ("▰"):rep(filled) .. ("▱"):rep(cells - filled)
end

local function state_chunk()
  local s = S.sess
  if not s then return "%#RailMuted#○ no session" end
  if s.state == "working" then
    local f = SPIN[math.floor(uv.hrtime() / 1e8) % #SPIN + 1]
    return "%#RailWork#" .. f .. " working" .. (s.tool and ("%#RailMuted# · " .. s.tool) or "")
  elseif s.state == "waiting" then
    return "%#RailWait# waiting for you"
  end
  return "%#RailOk#● idle"
end

--- Winbar string for the Claude window (evaluated by %!v:lua).
function M.header()
  local s = S.sess
  local parts = { " %#RailAccent#✿ Claude ", state_chunk() }
  if S.git.branch ~= "" then
    parts[#parts + 1] = ("%%#RailMuted# │ %%#RailBranch# %s"):format((S.git.branch:gsub("%%", "%%%%")))
    if S.git.files > 0 then parts[#parts + 1] = "%#RailMuted# ±" .. S.git.files end
  end
  local st = s and s.status or {}
  if st.model then parts[#parts + 1] = "%#RailMuted# │ %#RailText#" .. st.model end
  parts[#parts + 1] = "%="
  if st.ctx then
    local c = st.ctx >= 80 and "RailWait" or (st.ctx >= 50 and "RailWork" or "RailOk")
    parts[#parts + 1] = ("%%#RailMuted#ctx %%#%s#%s %%#RailMuted#%d%%%% "):format(c, gauge(st.ctx, 8), st.ctx)
  end
  if st.cost then parts[#parts + 1] = ("%%#RailMuted#│ %%#RailText#$%.2f "):format(st.cost) end
  return table.concat(parts)
end

local function claude_wins()
  local out = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    if vim.bo[b].buftype == "terminal" and vim.api.nvim_buf_get_name(b):match("claude") then out[#out + 1] = w end
  end
  return out
end

local function trunc(str, n)
  return vim.fn.strchars(str) > n and (vim.fn.strcharpart(str, 0, n - 1) .. "…") or str
end

-- A row is a list of { text, group } chunks; the rail buffer is built from them.
local BAR = "▎"

local function panel(title, subtitle, tone, body)
  local rows = {}
  local bar = { BAR .. " ", tone }
  rows[#rows + 1] = { bar }
  local head = { bar, { "✿ " .. title, "RailAccent" } }
  if subtitle and subtitle ~= "" then
    head[#head + 1] = { " · ", "RailMuted" }
    head[#head + 1] = { subtitle, "RailMuted" }
  end
  rows[#rows + 1] = head
  rows[#rows + 1] = { bar }
  for _, r in ipairs(body) do
    local row = { bar, { " ", "RailText" } }
    for _, c in ipairs(r) do row[#row + 1] = c end
    rows[#rows + 1] = row
  end
  rows[#rows + 1] = { bar }
  rows[#rows + 1] = {}
  return rows
end

local function kv(label, value, group)
  return { { ("%-8s"):format(label), "RailMuted" }, { value, group or "RailText" } }
end

local function card()
  local s = S.sess
  local st = s and s.status or {}
  local inner = WIDTH - 5
  local tone, label = "RailMuted", "no session"
  if s then
    if s.state == "working" then tone, label = "RailWork", "working" .. (s.tool and (" · " .. s.tool) or "")
    elseif s.state == "waiting" then tone, label = "RailWait", "waiting for you"
    else tone, label = "RailOk", "idle" end
  end

  local status = {
    kv("Project", trunc(vim.fs.basename(root()), inner - 8)),
    kv("Branch", trunc(S.git.branch ~= "" and S.git.branch or "-", inner - 8), "RailBranch"),
    kv("Model", st.model or "-"),
  }
  if st.ctx then
    local c = st.ctx >= 80 and "RailWait" or (st.ctx >= 50 and "RailWork" or "RailOk")
    status[#status + 1] = { { ("%-8s"):format("Context"), "RailMuted" }, { gauge(st.ctx, 8), c }, { (" %d%%"):format(st.ctx), "RailMuted" } }
  end
  if st.cost then status[#status + 1] = kv("Cost", ("$%.2f"):format(st.cost)) end
  local rows = panel("Status", label, tone, status)

  local g = S.git
  local body = {}
  for i, f in ipairs(g.list) do
    if i > 6 then
      body[#body + 1] = { { ("+%d more"):format(#g.list - 6), "RailMuted" } }
      break
    end
    local grp = f.st:find("[DU]") and "RailWait" or (f.st:find("[?A]") and "RailOk" or "RailWork")
    body[#body + 1] = { { ("%-2s "):format(f.st), grp }, { trunc(vim.fs.basename(f.path), inner - 4), "RailText" } }
  end
  if #body == 0 then body[1] = { { "clean", "RailMuted" } } else body[#body + 1] = { { "<leader>ae to browse", "RailMuted" } } end
  local sub = #g.list == 0 and "" or ("%d file%s · +%d -%d"):format(#g.list, #g.list == 1 and "" or "s", g.add, g.del)
  vim.list_extend(rows, panel("Changes", sub, "RailAccent", body))

  local todos = s and s.todos or {}
  if #todos > 0 then
    local done, tb = 0, {}
    for _, t in ipairs(todos) do
      if t.status == "completed" then done = done + 1 end
      local icon, grp = "○", "RailText"
      if t.status == "completed" then icon, grp = "✓", "RailMuted"
      elseif t.status == "in_progress" then icon, grp = "●", "RailWork" end
      tb[#tb + 1] = { { icon .. " ", grp }, { trunc(t.content or "", inner - 2), grp } }
    end
    vim.list_extend(rows, panel("Todos", ("%d of %d"):format(done, #todos), "RailAccent", tb))
  end
  return rows
end

local function rail_open() return S.win and vim.api.nvim_win_is_valid(S.win) end

local NS = vim.api.nvim_create_namespace("claude_rail")

local function draw_rail()
  if not rail_open() then return end
  local rows = card()
  local lines, spans = {}, {}
  for i, row in ipairs(rows) do
    local text, col = "", 0
    for _, c in ipairs(row) do
      spans[#spans + 1] = { i - 1, col, col + #c[1], c[2] }
      text, col = text .. c[1], col + #c[1]
    end
    lines[i] = text
  end
  vim.bo[S.buf].modifiable = true
  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
  vim.bo[S.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(S.buf, NS, 0, -1)
  for _, sp in ipairs(spans) do
    vim.api.nvim_buf_set_extmark(S.buf, NS, sp[1], sp[2], { end_col = sp[3], hl_group = sp[4] })
  end
end

local function zen_active()
  local z = package.loaded.snacks and Snacks.zen and Snacks.zen.win
  return z and z.valid and z:valid() or false
end

local function open_rail()
  if rail_open() then return end
  if not (S.buf and vim.api.nvim_buf_is_valid(S.buf)) then
    S.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[S.buf].bufhidden = "hide"
  end
  -- A real split (not a float): nvim reserves its width, so text wraps before reaching it and
  -- other widgets can be stacked in this column later. It sits just left of the Claude window.
  local cw = claude_wins()[1]
  S.win = vim.api.nvim_open_win(S.buf, false, cw and { split = "left", win = cw, width = WIDTH } or { split = "right", win = -1, width = WIDTH })
  for k, v in pairs({ number = false, relativenumber = false, signcolumn = "no", foldcolumn = "0", statuscolumn = "",
    cursorline = false, list = false, wrap = false, winfixwidth = true, spell = false, winbar = "" }) do
    vim.wo[S.win][k] = v
  end
  vim.wo[S.win].winhighlight = "Normal:RailPanel,NormalNC:RailPanel,EndOfBuffer:RailPanel"
  draw_rail()
end

local function close_rail()
  if rail_open() then pcall(vim.api.nvim_win_close, S.win, true) end
  S.win = nil
end

function M.toggle_rail()
  S.auto = false
  if rail_open() then close_rail() else open_rail() end
end

-- Zen mode takes the whole width: hide the rail while it is active, bring it back after.
local function sync_zen()
  if zen_active() then
    if rail_open() then S.zen_hid = true close_rail() end
  elseif S.zen_hid then
    S.zen_hid = nil
    open_rail()
  end
end

local function apply_winbar()
  for _, w in ipairs(claude_wins()) do
    vim.wo[w].winbar = "%!v:lua.require'config.claude_rail'.header()"
    vim.wo[w].winhighlight = "WinBar:RailPanel,WinBarNC:RailPanel"
  end
end

local function refresh()
  load_session()
  load_git()
  apply_winbar()
  if S.auto and (S.sess or #claude_wins() > 0) and not rail_open() and not zen_active() then open_rail() end
  draw_rail()
  pcall(vim.cmd, "redrawstatus!")
end

function M.setup()
  vim.fn.mkdir(DIR, "p")
  highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = highlights })
  vim.api.nvim_create_autocmd({ "TermOpen", "WinEnter", "WinNew", "WinClosed", "BufWinEnter", "VimResized" }, {
    callback = function() vim.schedule(function() apply_winbar() if S.auto and (S.sess or #claude_wins() > 0) and not rail_open() and not zen_active() then open_rail() end draw_rail() sync_zen() end) end,
  })

  local w = uv.new_fs_event()
  w:start(DIR, {}, function() vim.schedule(refresh) end)
  -- Spinner: only repaint while Claude is working.
  local t = uv.new_timer()
  t:start(0, 120, vim.schedule_wrap(function()
    if S.sess and S.sess.state == "working" then pcall(vim.cmd, "redrawstatus!") end
  end))
  vim.api.nvim_create_autocmd("VimLeavePre", { callback = function() pcall(w.stop, w) pcall(t.stop, t) end })

  vim.keymap.set("n", "<leader>aR", M.toggle_rail, { desc = "Claude rail (status/changes/todos)" })
  refresh()
end

return M
