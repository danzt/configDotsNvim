-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Project panel siempre visible al abrir nvim (estilo WebStorm)
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Auto-open Neo-tree on startup",
  callback = function()
    if vim.bo.filetype ~= "gitcommit" then
      require("neo-tree.command").execute({ action = "show" })
    end
  end,
})

-- Auto-activar render-markdown al salir del modo insert en archivos markdown
vim.api.nvim_create_autocmd("InsertLeave", {
  desc = "Enable render-markdown on InsertLeave",
  pattern = "*.md",
  callback = function()
    local ok, render = pcall(require, "render-markdown")
    if ok then
      render.enable()
    end
  end,
})

-- Tree of files Claude Code edited (hook-fed); <leader>ae
require("config.claude_edits").setup()

require("config.claude_rail").setup()
