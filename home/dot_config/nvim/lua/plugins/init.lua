local isVscode = vim.g.vscode == 1

return {
	"tpope/vim-repeat",

	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- For https://github.com/luckasRanarison/tree-sitter-hypr
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.hypr = {
				install_info = {
					url = "https://github.com/luckasRanarison/tree-sitter-hypr",
					files = { "src/parser.c" },
					branch = "master",
				},
				filetype = "hypr",
			}

			require("nvim-treesitter.configs").setup({
				ensure_installed = { "vimdoc", "javascript", "typescript", "lua", "svelte" },
				sync_install = false,
				auto_install = true,

				highlight = {
					enable = vim.g.vscode == nil or not vim.g.vscode,
				},

				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["ia"] = "@parameter.inner",
							["aa"] = "@parameter.outer",
						},
						include_surrounding_whitespace = true,
					},
					move = {
						enable = true,
						goto_next_start = {
							["]m"] = "@function.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
						},
					},
				},

				endwise = {
					enable = true,
				},

				textsubjects = {
					enable = true,
					prev_selection = ",",
					keymaps = {
						["."] = "textsubjects-smart",
						[";"] = "textsubjects-container-outer",
						["i;"] = "textsubjects-container-inner",
					},
				},
			})
		end,
	},
	{
		"nat-418/boole.nvim",
		config = function()
			require("boole").setup({
				mappings = {
					increment = "<C-a>",
					decrement = "<C-x>",
				},
			})
		end,
	},

	{ 'echasnovski/mini.ai', version = '*'  },
	{ 'echasnovski/mini.move', version = '*' },

	--  -----------------------------------------------
	--  Plugins for Neovim in the terminal
	--  -----------------------------------------------
	{ "tpope/vim-commentary", cond = not isVscode },
	{ "luckasRanarison/tree-sitter-hypr", cond = not isVscode },
	{ "NvChad/nvim-colorizer.lua", config = true, cond = not isVscode },
	{ "nvim-tree/nvim-web-devicons", cond = not isVscode },

	{ 'echasnovski/mini.visits', version = '*', cond = not isVscode },
	{ 'echasnovski/mini.statusline', version = '*', cond = not isVscode },
	{ 'echasnovski/mini.pairs', version = '*', cond = not isVscode },
	{ 'echasnovski/mini.cursorword', version = '*', cond = not isVscode },
	{ 'echasnovski/mini.comment', version = '*', cond = not isVscode },
	{ 'echasnovski/mini.fuzzy', version = '*', cond = not isVscode },
	{ 'echasnovski/mini-git', version = '*', cond = not isVscode },
	{ 'echasnovski/mini.animate', version = '*', cond = not isVscode },
	{
    'fei6409/log-highlight.nvim',
		cond = not isVscode,
    config = function()
        require('log-highlight').setup {}
    end,
},


	{
		"nvim-tree/nvim-tree.lua",
		cond = not isVscode,
		config = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			vim.opt.termguicolors = true

			vim.keymap.set("n", "<c-e>", ":NvimTreeFindFileToggle<CR>")

			require("nvim-tree").setup({
				view = {
					adaptive_size = true,
				},
			})

			-- vim.cmd("autocmd Colorscheme * highlight NvimTreeNormal guibg=#00000000 guifg=#9da5b3")
		end,
	},
}
