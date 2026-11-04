-- blink.cmp — sources configuration
-- Adds CodeCompanion completions on top of LazyVim defaults (lsp, path, snippets, buffer)
return {
  "saghen/blink.cmp",
  optional = true,
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "codecompanion" },
      providers = {
        codecompanion = {
          name    = "CodeCompanion",
          module  = "codecompanion.providers.completion.blink",
          enabled = true,
        },
        -- Disable path completion inside copilot-chat buffers (slash commands clash)
        path = {
          enabled = function()
            return vim.bo.filetype ~= "copilot-chat"
          end,
        },
      },
    },
  },
}
