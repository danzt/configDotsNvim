return {
  -- Project panel estilo WebStorm: sigue el archivo activo y se refresca solo
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = { width = 32 },
    },
  },

  -- Diagnostics mejorados
  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
  },

  -- Symbols outline — reemplaza symbols-outline.nvim (abandonado)
  -- Más rápido, activamente mantenido, integra con snacks/telescope
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    cmd = "AerialToggle",
    keys = { { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Symbols Outline (Aerial)" } },
    opts = {
      layout = { default_direction = "right" },
      attach_mode = "global",
    },
  },

  -- LSP config
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        angularls = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("angular.json", "project.json")(fname)
          end,
        },
        nil_ls = {
          cmd = { "nil" },
          autostart = true,
          mason = false,
          settings = {
            ["nil"] = {
              formatting = { command = { "nixpkgs-fmt" } },
            },
          },
        },
      },
    },
  },
}
