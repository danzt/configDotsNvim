-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0
vim.opt.laststatus = 3

-- set the colorscheme
vim.cmd("colorscheme kanagawa-wave")
