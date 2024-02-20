require("danztNvim.settings")
require("danztNvim.maps")
require("danztNvim.plugins")
require("danztNvim.utils")
local themeStatus, kanagawa = pcall(require, "kanagawa")

if themeStatus then
	vim.cmd("colorscheme material-deep-ocean")
else
	return
end
-- Configuración de Warp

vim.cmd([[highlight Directory guifg=#ff00ff gui=bold]])
vim.g.warp_enabled = 1
vim.g.warp_italic = 1
vim.g.warp_bold = 1
