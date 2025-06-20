return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
	init = function()
		if vim.g.vscode then
			local highlights = {
				FlashBackdrop = { bg = "#1c1c1c" },
				FlashMatch = { bg = "black", fg = "#e78a4e" },
				FlashCurrent = { bg = "black", fg = "#c5b18d" },
				FlashLabel = { bg = "#fda697", fg = "#101010" },
			}

			for hl_group, hl_def in pairs(highlights) do
				print("Setting highlight for", hl_group, "with", vim.inspect(hl_def))
				vim.api.nvim_set_hl(0, hl_group, hl_def)
			end
		else
			local augroup = vim.api.nvim_create_augroup("FlashColors", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = augroup,
				pattern = "*",
				command = "highlight FlashBackdrop guibg=#1c1c1c",
			})
		end
	end,
}
