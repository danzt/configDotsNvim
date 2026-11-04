local mode = {
  "mode",
  fmt = function(s)
    local mode_map = {
      ["NORMAL"] = "N",
      ["O-PENDING"] = "N?",
      ["INSERT"] = "I",
      ["VISUAL"] = "V",
      ["V-BLOCK"] = "VB",
      ["V-LINE"] = "VL",
      ["V-REPLACE"] = "VR",
      ["REPLACE"] = "R",
      ["COMMAND"] = "!",
      ["SHELL"] = "SH",
      ["TERMINAL"] = "T",
      ["EX"] = "X",
      ["S-BLOCK"] = "SB",
      ["S-LINE"] = "SL",
      ["SELECT"] = "S",
      ["CONFIRM"] = "Y?",
      ["MORE"] = "M",
    }
    return mode_map[s] or s
  end,
}

local function codecompanion_adapter_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  if not chat then
    return nil
  end
  return " " .. chat.adapter.formatted_name
end

local function codecompanion_current_model_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  if not chat then
    return nil
  end
  return chat.settings.model
end

return {
  { "folke/todo-comments.nvim", version = "*" },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { preset = "classic", win = { border = "single" } },
  },

  {
    "amrbashir/nvim-docs-view",
    lazy = true,
    cmd = "DocsViewToggle",
    opts = { position = "right", width = 60 },
  },

  -- Noice — reemplaza cmdline, messages y notifications con una UI moderna
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
  },

  -- mini.animate — scroll suave y animaciones de ventana
  {
    "nvim-mini/mini.animate",
    event = "VeryLazy",
    opts = {
      scroll = { enable = false },
      cursor = { enable = false },
      resize = { enable = false },
      open = { enable = false },
      close = { enable = false },
    },
  },

  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
    opts = {
      options = {
        theme = "gentleman-kanagawa-blur",
        icons_enabled = true,
      },
      sections = {
        lualine_a = { { "mode", icon = "󱗞" } },
      },
      extensions = {
        "quickfix",
        {
          filetypes = { "oil" },
          sections = {
            lualine_a = { mode },
            lualine_b = {
              function()
                local ok, oil = pcall(require, "oil")
                if not ok then
                  return ""
                end
                local path = vim.fn.fnamemodify(oil.get_current_dir(), ":~")
                return path .. " %m"
              end,
            },
          },
        },
        {
          filetypes = { "codecompanion" },
          sections = {
            lualine_a = { mode },
            lualine_b = { codecompanion_adapter_name },
            lualine_c = { codecompanion_current_model_name },
            lualine_x = {},
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = { codecompanion_adapter_name },
            lualine_c = {},
            lualine_x = {},
            lualine_y = { "progress" },
            lualine_z = {},
          },
        },
      },
    },
  },

  -- incline — filename flotante por ventana
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    config = function()
      require("incline").setup({
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = { cursorline = true },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end
          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },

  -- zen mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
        kitty = { enabled = false, font = "+2" },
        twilight = { enabled = true },
      },
    },
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },

  -- snacks
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Find Buffers",
      },
    },
    opts = {
      notifier = {},
      image = {},
      picker = {
        exclude = { ".git", "node_modules" },
        matcher = {
          fuzzy = true,
          smartcase = true,
          ignorecase = true,
          filename_bonus = true,
        },
      },
      dashboard = {
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = [[
        ____                               __
        /\  _`\                            /\ \__
        \ \ \/\ \     __       ___    ____ \ \ ,_\
        \ \ \ \ \  /'__`\   /' _ `\ /\_ ,`\\ \ \/
          \ \ \_\ \/\ \L\.\_ /\ \/\ \\/_/  /_\ \ \_
          \ \____/\ \__/.\_\\ \_\ \_\ /\____\\ \__\
            \/___/  \/__/\/_/ \/_/\/_/ \/____/ \/__/
          ]],
          keys = {
            { icon = " ", key = "ff", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },
}
