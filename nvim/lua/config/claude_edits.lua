-- Tree of the files Claude Code edited in this project.
-- Fed by ~/.claude/hooks/record-edits.sh (PostToolUse on Edit/Write/MultiEdit/NotebookEdit).
-- <leader>ae toggles the panel; in it: <CR> open, d open + diff vs HEAD, r refresh, x clear, q close.
local M = {}

local uv = vim.uv or vim.loop
local STATE_DIR = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")) .. "/claude-edits"
local LOG = STATE_DIR .. "/edits.jsonl"

local S = { buf = nil, win = nil, lines = {}, since = 0, seen = 0 }

local function root()
  local cwd = uv.cwd()
  return vim.fs.root(cwd, ".git") or cwd
end

--- Edited files for the current project, newest state: { [abs path] = { n = edits, ts = last } }
local function read_edits()
  local files, r = {}, root() .. "/"
  local f = io.open(LOG, "r")
  if not f then return files end
  for line in f:lines() do
    local ok, e = pcall(vim.json.decode, line)
    if ok and e.path and e.ts and e.ts >= S.since and vim.startswith(e.path, r) then
      S.last = e.path -- log is chronological, so this ends as the newest edit
      local cur = files[e.path] or { n = 0 }
      cur.n, cur.ts = cur.n + 1, e.ts
      files[e.path] = cur
    end
  end
  f:close()
  return files
end

local function render()
  local files = read_edits()
  local r = root() .. "/"
  local rels = vim.tbl_keys(files)
  table.sort(rels)
  S.lines = {}
  local out, hl = { "" }, {}
  local prev = {}
  for _, abs in ipairs(rels) do
    local rel = abs:sub(#r + 1)
    local segs = vim.split(rel, "/", { plain = true })
    local file = table.remove(segs)
    local common = 0
    while common < #segs and prev[common + 1] == segs[common + 1] do common = common + 1 end
    for i = common + 1, #segs do
      out[#out + 1] = string.rep("  ", i - 1) .. " " .. segs[i] .. "/"
      hl[#out] = "Directory"
    end
    prev = segs
    local exists = uv.fs_stat(abs) ~= nil
    local n = files[abs].n
    out[#out + 1] = string.rep("  ", #segs) .. "  " .. file .. (exists and "" or "  (deleted)") .. (n > 1 and ("  ×" .. n) or "")
    S.lines[#out] = abs
    hl[#out] = exists and "Normal" or "Comment"
  end
  out[1] = (" Claude edits · %d file%s"):format(#rels, #rels == 1 and "" or "s")
  hl[1] = "Title"
  if #rels == 0 then out[2] = "  nothing edited yet" hl[2] = "Comment" end
  S.count = #rels

  if not (S.buf and vim.api.nvim_buf_is_valid(S.buf)) then return end
  vim.bo[S.buf].modifiable = true
  vim.api.nvim_buf_set_lines(S.buf, 0, -1, false, out)
  vim.bo[S.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(S.buf, -1, 0, -1)
  for lnum, group in pairs(hl) do
    vim.api.nvim_buf_add_highlight(S.buf, -1, group, lnum - 1, 0, -1)
  end
end

local function is_open() return S.win and vim.api.nvim_win_is_valid(S.win) end

local function target_win()
  -- A normal window other than the panel, preferring the previous one.
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  local function ok(w) return w ~= S.win and vim.api.nvim_win_is_valid(w) and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" end
  if ok(prev) then return prev end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if ok(w) then return w end
  end
end

local function open_file(diff)
  local abs = S.lines[vim.fn.line(".")]
  if not abs then return end
  local w = target_win()
  if w then vim.api.nvim_set_current_win(w) else vim.cmd("topleft vsplit") end
  vim.cmd("edit " .. vim.fn.fnameescape(abs))
  if diff then
    local ok, gs = pcall(require, "gitsigns")
    if ok then gs.diffthis("HEAD") else vim.notify("gitsigns not available", vim.log.levels.WARN) end
  end
end

local function open_panel(focus)
  if is_open() then
    if focus then vim.api.nvim_set_current_win(S.win) end
    return
  end
  local from = vim.api.nvim_get_current_win()
  if not (S.buf and vim.api.nvim_buf_is_valid(S.buf)) then
    S.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[S.buf].buftype, vim.bo[S.buf].bufhidden = "nofile", "hide"
    vim.bo[S.buf].swapfile, vim.bo[S.buf].filetype = false, "claude-edits"
    local function map(lhs, fn, desc) vim.keymap.set("n", lhs, fn, { buffer = S.buf, nowait = true, desc = desc }) end
    map("<CR>", function() open_file(false) end, "Open file")
    map("o", function() open_file(false) end, "Open file")
    map("d", function() open_file(true) end, "Open file + diff vs HEAD")
    map("r", render, "Refresh")
    map("x", function() S.since = os.time() render() end, "Clear list")
    map("q", function() M.close() end, "Close")
  end
  -- Dock mode (the dedicated edits tab) pins the tree as a left sidebar; otherwise a bottom split.
  vim.cmd(S.dock and "topleft 34vsplit" or "botright 14split")
  S.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(S.win, S.buf)
  for k, v in pairs({ number = false, relativenumber = false, signcolumn = "no", wrap = false, cursorline = true, winfixheight = not S.dock, winfixwidth = S.dock or false, list = false }) do
    vim.wo[S.win][k] = v
  end
  render()
  if not focus and vim.api.nvim_win_is_valid(from) then vim.api.nvim_set_current_win(from) end
end

function M.close()
  if is_open() then vim.api.nvim_win_close(S.win, true) end
  S.win = nil
end

function M.toggle()
  if is_open() then M.close() else open_panel(true) end
end

--- Open the file Claude just edited in an editor window, without moving focus.
local function follow()
  local path = S.last
  if not (S.follow and path and uv.fs_stat(path)) then return end
  local w
  for _, c in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(c)
    if c ~= S.win and vim.api.nvim_win_get_config(c).relative == "" and vim.bo[b].buftype ~= "terminal"
      and vim.bo[b].filetype ~= "claude-edits" then
      w = c
      break
    end
  end
  if not w then return end
  local b = vim.api.nvim_win_get_buf(w)
  if vim.bo[b].modified or vim.api.nvim_buf_get_name(b) == path then return end -- never clobber unsaved work
  vim.api.nvim_win_call(w, function() vim.cmd("silent! edit " .. vim.fn.fnameescape(path)) end)
end

local function on_log_change()
  vim.schedule(function()
    pcall(vim.cmd, "checktime") -- buffers Claude just rewrote on disk
    local before = S.count or 0
    if is_open() then render() else
      -- count without drawing, to decide whether to auto-open
      S.count = vim.tbl_count(read_edits())
    end
    if not is_open() and (S.count or 0) > before then open_panel(false) end
    read_edits() -- refreshes S.last
    follow()
  end)
end

function M.setup()
  vim.fn.mkdir(STATE_DIR, "p")
  -- CLAUDE_EDITS_TAB=1 (see claude/edits-nvim): this nvim is the dedicated edits tab next to a Claude pane.
  -- It docks the tree on the left, keeps the history of the last 12h and starts the claudecode.nvim
  -- server so Claude's /ide can connect and send its diffs here.
  S.dock = vim.env.CLAUDE_EDITS_TAB == "1"
  S.since = os.time() - (S.dock and 12 * 3600 or 0) -- otherwise start fresh each nvim session
  S.count = 0
  local w = uv.new_fs_event()
  w:start(STATE_DIR, {}, function(err, name)
    if not err and name == "edits.jsonl" then on_log_change() end
  end)
  vim.api.nvim_create_autocmd("VimLeavePre", { callback = function() pcall(w.stop, w) end })

  S.follow = true
  vim.keymap.set("n", "<leader>aF", function()
    S.follow = not S.follow
    vim.notify("Claude follow: " .. (S.follow and "on" or "off"))
  end, { desc = "Toggle auto-open of files Claude edits" })
  vim.keymap.set("n", "<leader>ae", M.toggle, { desc = "Claude edited files" })
  if S.dock then
    vim.schedule(function()
      pcall(function() require("lazy").load({ plugins = { "claudecode.nvim" } }) end)
      open_panel(false)
    end)
  end
  vim.api.nvim_create_user_command("ClaudeEdits", M.toggle, { desc = "Toggle the Claude edited files tree" })
end

return M
