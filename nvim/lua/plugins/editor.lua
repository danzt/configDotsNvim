return {
  -- Preview de definiciones, referencias e implementaciones en floating window
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = true,
    keys = {
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",      noremap = true, desc = "Preview definition" },
      { "gpD", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",     noremap = true, desc = "Preview declaration" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",  noremap = true, desc = "Preview implementation" },
      { "gpy", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", noremap = true, desc = "Preview type definition" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>",      noremap = true, desc = "Preview references" },
      { "gP",  "<cmd>lua require('goto-preview').close_all_win()<CR>",               noremap = true, desc = "Close all previews" },
    },
  },

  -- Auto-cierre y rename de tags en JSX/TSX/HTML
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- Split/join bloques de código (objetos, arrays, args de funciones)
  -- <leader>m para toggle, <leader>mj join, <leader>ms split
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>m",  function() require("treesj").toggle() end, desc = "Toggle split/join block" },
      { "<leader>mj", function() require("treesj").join() end,   desc = "Join block" },
      { "<leader>ms", function() require("treesj").split() end,  desc = "Split block" },
    },
    opts = { use_default_keymaps = false },
  },
}
