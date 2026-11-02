-- Gentle-Shell-style header + rail for Claude Code, driven by live state from
--   ~/.claude/hooks/claude-state.sh (hooks: working/tool/post/waiting/idle) and ~/.claude/statusline.sh (model/ctx/cost).
-- The header is a winbar on the Claude terminal window; the rail is a floating card (<leader>aR).
local M = {}

local uv = vim.uv or vim.loop
local DIR = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")) .. "/claude-state"
local WIDTH = 36
local SPIN = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local S = { sess = nil, git = { branch = "", files = 0, add = 0, del = 0 }, win = nil, buf = nil, auto = true }

-- Colors come from the active colorscheme so the rail always matches the theme.
local function highlights()
  local links = {
    RailWork = "DiagnosticWarn", RailOk = "DiagnosticOk", RailWait = "DiagnosticError",
    RailAccent = "Title", RailMuted = "Comment", RailBranch = "Special", RailText = "Normal",
  }
  for name, link in pairs(links) do vim.api.nvim_set_hl(0, name, { link = link, default = true }) end
end

local function root()
  local cwd = uv.cwd()
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
    vim.schedule(function() S.git.branch, S.git.files = head, math.max(#lines - 1, 0) end)
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
  local parts = { " %#RailAccent#✻ Claude ", state_chunk() }
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

local function card()
  local lines, hl = {}, {}
  local function add(text, group) lines[#lines + 1] = text hl[#lines] = group end
  local s = S.sess
  local st = s and s.status or {}
  add(" Status", "RailAccent")
  add("  Project  " .. trunc(vim.fs.basename(root()), WIDTH - 14), "RailText")
  add("  Branch   " .. trunc(S.git.branch ~= "" and S.git.branch or "-", WIDTH - 14), "RailBranch")
  add("  Model    " .. (st.model or "-"), "RailText")
  add("", "RailText")
  add(" Changes", "RailAccent")
  add(("  %d file%s · +%d -%d"):format(S.git.files, S.git.files == 1 and "" or "s", S.git.add, S.git.del), "RailText")
  add("  <leader>ae to browse", "RailMuted")
  local todos = s and s.todos or {}
  if #todos > 0 then
    local done = 0
    for _, t in ipairs(todos) do if t.status == "completed" then done = done + 1 end end
    add("", "RailText")
    add((" Todos · %d of %d"):format(done, #todos), "RailAccent")
    for _, t in ipairs(todos) do
      local icon, g = "○", "RailText"
      if t.status == "completed" then icon, g = "✓", "RailMuted"
      elseif t.status == "in_progress" then icon, g = "●", "RailWork" end
      add("  " .. icon .. " " .. trunc(t.content or "", WIDTH - 6), g)
    end
  end
  return lines, hl
end

local function rail_open() return S.win and vim.api.nvim_win_is_valid(S.win) end

local function draw_rail()
  if not rail_open() then return end
  local lines, hl = card()
  vim.bo[S.buf].modifiable = true
  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
  vim.bo[S.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(S.buf, -1, 0, -1)
  for i, g in pairs(hl) do vim.api.nvim_buf_add_highlight(S.buf, -1, g, i - 1, 0, -1) end
  -- Sit just left of the Claude window (or at the right edge when there is none).
  local cw = claude_wins()[1]
  local col = cw and vim.api.nvim_win_get_position(cw)[2] - 1 or vim.o.columns - 1
  vim.api.nvim_win_set_config(S.win, { relative = "editor", row = 1, col = math.max(col, WIDTH + 1), height = #lines, width = WIDTH })
end

function M.toggle_rail()
  S.auto = false
  if rail_open() then vim.api.nvim_win_close(S.win, true) S.win = nil return end
  if not (S.buf and vim.api.nvim_buf_is_valid(S.buf)) then
    S.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[S.buf].bufhidden = "hide"
  end
  S.win = vim.api.nvim_open_win(S.buf, false, {
    relative = "editor", anchor = "NE", row = 1, col = vim.o.columns - 1, width = WIDTH, height = 8,
    style = "minimal", border = "rounded", focusable = false, zindex = 40, title = " ✻ Claude ", title_pos = "left",
  })
  vim.wo[S.win].winhighlight = "NormalFloat:Normal,FloatBorder:RailMuted,FloatTitle:RailAccent"
  draw_rail()
end

local function apply_winbar()
  for _, w in ipairs(claude_wins()) do
    vim.wo[w].winbar = "%!v:lua.require'config.claude_rail'.header()"
  end
end

local function refresh()
  load_session()
  load_git()
  apply_winbar()
  if S.auto and S.sess and not rail_open() and vim.o.columns >= 180 then M.toggle_rail() S.auto = true end
  draw_rail()
  pcall(vim.cmd, "redrawstatus!")
end

function M.setup()
  vim.fn.mkdir(DIR, "p")
  highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = highlights })
  vim.api.nvim_create_autocmd({ "TermOpen", "WinEnter", "BufWinEnter", "VimResized" }, {
    callback = function() vim.schedule(function() apply_winbar() draw_rail() end) end,
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
