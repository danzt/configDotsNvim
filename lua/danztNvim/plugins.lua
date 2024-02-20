-- Automatically run: PackerCompile
vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("PACKER", { clear = true }),
	pattern = "plugins.lua",
	command = "source <afile> | PackerCompile",
})

return require("packer").startup(function(use)
	-- Packer
	use("wbthomason/packer.nvim")

	---- Common utilities
	--use("nvim-lua/plenary.nvim")

	---- Icons
	--use("nvim-tree/nvim-web-devicons")

	---- Colorschema
	--use("rebelot/kanagawa.nvim")

	--use("Mofiqul/dracula.nvim")

	use("marko-cerovac/material.nvim")
	---- use("joshdick/onedark.vim")
	use("EdenEast/nightfox.nvim")

	use({ "navarasu/onedark.nvim", require("onedark").setup({
		style = "deep",
	}) })

	--use("posva/vim-vue")

	use("tpope/vim-commentary")

	---- File manager
	use("rktjmp/lush.nvim") -- Dependencia para temas Lush

	-- Common utilities
	use("nvim-lua/plenary.nvim")

	-- Icons
	use("nvim-tree/nvim-web-devicons")
	use("ryanoasis/vim-devicons")

	-- Colorschema
	use("rebelot/kanagawa.nvim")

	-- use({
	-- 	"folke/tokyonight.nvim",
	-- 	config = function()
	-- 		require("danztNvim.configs.tokyonight")
	-- 	end,
	-- })

	use({
		"uloco/bluloco.nvim",
		requires = { "rktjmp/lush.nvim" },
	})

	-- Statusline
	use({
		"nvim-lualine/lualine.nvim",
		event = "BufEnter",
		config = function()
			require("danztNvim.configs.lualine")
		end,
		requires = { "nvim-web-devicons" },
	})

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		commit = "8e763332b7bf7b3a426fd8707b7f5aa85823a5ac",

		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		config = function()
			require("danztNvim.configs.nvim-treesitter-update")
		end,
	})

	use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" })

	-- Telescope
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		requires = { { "nvim-lua/plenary.nvim" }, { "nvim-telescope/telescope-fzf-native.nvim" } },
	})

	-- FZF
	use({
		"junegunn/fzf",
		requires = { { "junegunn/fzf.vim" } },
	})

	-- LSP
	use({
		"neovim/nvim-lspconfig",
		config = function()
			require("danztNvim.configs.lsp")
		end,
	})

	use("onsails/lspkind-nvim")
	use({
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		tag = "v<CurrentMajor>.*",
	})

	-- cmp: Autocomplete
	use({
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			require("danztNvim.configs.cmp")
		end,
	})

	use("hrsh7th/cmp-nvim-lsp")

	use({ "hrsh7th/cmp-path", after = "nvim-cmp" })

	use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })

	-- LSP diagnostics, code actions, and more via Lua.
	use({
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			require("danztNvim.configs.null-ls")
		end,
		requires = { "nvim-lua/plenary.nvim" },
	})

	-- Mason: Portable package manager
	use({
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	})

	use({
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("danztNvim.configs.mason-lsp")
		end,
		after = "mason.nvim",
	})

	-- File manager
	use({
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
	})

	-- Show colors
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "*" })
		end,
	})

	-- Terminal
	use({
		"akinsho/toggleterm.nvim",
		tag = "*",
		config = function()
			require("danztNvim.configs.toggleterm")
		end,
	})

	-- Git
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("danztNvim.configs.gitsigns")
		end,
	})
	use({ "tpope/vim-fugitive" })

	-- Markdown Preview
	use({
		"iamcco/markdown-preview.nvim",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	})

	-- autopairs
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("danztNvim.configs.autopairs")
		end,
	})

	--Autocomplete Codeium
	use({ "Exafunction/codeium.vim" })

	-- Schemes themes.
	use({ "Alexis12119/nightly.nvim" })
	use({ "space-chalk/spacechalk.nvim" })
	use({ "Tsuzat/NeoSolarized.nvim" })
	use("ayu-theme/ayu-vim")

	use({ "catppuccin/nvim", as = "catppuccin" })

	-- Tema Base16 Material Darker
	use({
		"eddyekofo94/gruvbox-flat.nvim",
		requires = { "rktjmp/lush.nvim" },
		config = function()
			vim.g.gruvbox_flat_style = "dark"
		end,
	})

	-- Tema OneDark
	use({
		"navarasu/onedark.nvim",
		config = function() end,
	})

	-- Tema Dracula
	use({
		"dracula/vim",
		as = "dracula",
		config = function() end,
	})

	-- Tema Solarized (modo claro)

	-- use({
	-- 	"chikko80/error-lens.nvim",
	-- 	config = function()
	-- 		require("slydragonn.configs.lens")
	-- 	end,
	-- })

	-- Theme General
	-- Install without configuration
	--use({ "projekt0n/github-nvim-theme" })

	-- Or with configuration
	use({
		"projekt0n/github-nvim-theme",
		config = function()
			require("github-theme").setup({
				-- ...
			})

			--vim.cmd("colorscheme github_dark")
			--vim.cmd("colorscheme github_dark_tritanopia")
		end,
	})

	use("shaunsingh/nord.nvim")

	use({
		"marko-cerovac/material.nvim",
		config = function()
			require("material").setup({
				contrast = true, -- Activa el modo de contraste
				borders = false, -- Desactiva los bordes
				italics = {
					comments = true, -- Activa cursiva para comentarios
					keywords = false, -- Desactiva cursiva para palabras clave
					functions = false, -- Desactiva cursiva para funciones
					strings = false, -- Desactiva cursiva para cadenas de texto
					variables = false, -- Desactiva cursiva para variables
				},
				disable = {
					background = false, -- Activa el fondo del tema
					term_colors = false, -- Activa los colores de la terminal
					eob_lines = false, -- Activa las líneas EOF
				},
			})
		end,
	})
	use("mhartington/formatter.nvim") -- Dependencia requerida por Purify
	use("romgrk/barbar.nvim") -- Dependencia requerida por Purify

	use({
		"kyazdani42/nvim-tree.lua",
		--requires = "kyazdani42/nvim-web-devicons",
	})
	use("bluz71/vim-nightfly-colors")
	use({ "rose-pine/neovim", as = "rose-pine" })

	use("drewtempelmeyer/palenight.vim")

	use({ "folke/which-key.nvim" })

	--wakatime
	--use("wakatime/vim-wakatime")

	--indentlines

	use({ "lukas-reineke/indent-blankline.nvim", commit = "db7cbcb40cc00fc5d6074d7569fb37197705e7f6" })

	--Alpha
	use({ "goolord/alpha-nvim", commit = "0bb6fc0646bcd1cdb4639737a1cee8d6e08bcc31" })

	use({ "lewis6991/impatient.nvim" })

	--use({ "nvim-lua/plenary.nvim" }) -- Useful lua functions used by lots of plugins

	use({ "numToStr/Comment.nvim" })
	use({ "rafamadriz/friendly-snippets" }) -- a bunch of snippets to use
	use({ "RRethy/vim-illuminate" })

	use({ "akinsho/bufferline.nvim", commit = "83bf4dc7bff642e145c8b4547aa596803a8b4dc4" })
end)
