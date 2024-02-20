local M = {}
local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

local status, telescope = pcall(require, "telescope.builtin")
if status then
	-- Telescope
	map("n", "<leader>fa", "<CMD> lua require('telescope.builtin').find_files({hidden = true})<CR>")
	map("n", "<leader>tm", "<CMD> lua require('telescope.builtin').colorscheme()<CR>")

	map("n", "<leader>gd", "<CMD> lua require('telescope.builtin').lsp_definitions()<CR>")
	map("n", "<leader>gy", "<CMD> lua require('telescope.builtin').lsp_type_definitions()<CR>")
	map("n", "<leader>gi", "<CMD> lua require('telescope.builtin').lsp_implementations()<CR>")
	map("n", "<leader>gD", "<CMD> lua require('telescope.builtin').diagnostics()<CR>")

	map("n", "<leader>ct", "<CMD> lua require('telescope.builtin').treesitter()<CR>")

	-- maps find
	map("n", "<leader>ff", telescope.find_files)
	map("n", "<leader>fg", telescope.live_grep)
	map("n", "<leader>fb", telescope.buffers)
	map("n", "<leader>fh", telescope.help_tags)
	map("n", "<leader>fs", telescope.git_status)
	map("n", "<leader>fc", telescope.git_commits)
else
	print("Telescope not found")
end

-- coc keymaps
-- map("s", "gd", "<CMD> coc-definition <CR>")
-- map("s", "gy", "<CMD> coc-type-definition <CR>")
-- map("s", "gi", "<CMD> coc-implementation <CR>")
-- map("s", "gr", "<CMD> coc-preferences <CR>")
-- map("n", "<leader>f", "<CMD>coc-format-selected<CR>")

-- <leader> = the space key

-- Save
map("n", "<leader>w", "<CMD>update<CR>")

-- Quit
map("n", "<leader>q", "<CMD>q<CR>")

-- Exit insert mode
map("i", "jk", "<ESC>")

-- Windows
map("n", "<leader>ñ", "<CMD>vsplit<CR>")
map("n", "<leader>p", "<CMD>split<CR>")

-- kNeoTree
map("n", "<leader>e", "<CMD>Neotree toggle<CR>")
map("n", "<leader>o", "<CMD>Neotree focus<CR>")

-- Buffer
map("n", "<TAB>", "<CMD>bnext<CR>")
map("n", "<S-TAB>", "<CMD>bprevious<CR>")

-- Terminal
map("n", "<leader>th", "<CMD>ToggleTerm size=10 direction=horizontal<CR>")
map("n", "<leader>tv", "<CMD>ToggleTerm size=80 direction=vertical<CR>")

-- Markdown Preview
map("n", "<leader>m", "<CMD>MarkdownPreview<CR>")
map("n", "<leader>mn", "<CMD>MarkdownPreviewStop<CR>")

-- Window Navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-j>", "<C-w>j")

-- Resize Windows
map("n", "<C-Left>", "<C-w><")
map("n", "<C-Right>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")
map("n", "<leader>/", "<CMD>Commentary<CR>")

-- Clear selected
map("n", "<leader>nh", "<CMD>nohlsearch<CR>")

-- reload nvim
map("n", "<leader>so", "<CMD>source<CR>")

-- Bufferline keymaps
map("n", "<leader>bp", "<CMD>BufferPin<CR>")
map("n", "<leader>x", "<CMD>BufferClose<CR>")
map("n", "<leader>bx", "<CMD>BufferCloseAllButCurrent<CR>")
map("n", "<leader>bL", "<CMD>BufferCloseAllButPinned<CR>")
map("n", "<leader>bl", "<CMD>Buffers<CR>")

-- Autocomplete
function _G.check_back_space()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end
