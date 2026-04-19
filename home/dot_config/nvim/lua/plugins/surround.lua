return {
	"kylechui/nvim-surround",
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup(
	)


    -- See `:h nvim-surround.options`
    -- See `:h nvim-surround.keymaps`
	-------------------------------
    vim.keymap.set("n", "yo", "<Plug>(nvim-surround-normal)", {
        desc = "Add a surrounding pair around a motion (normal mode)",
    })
    vim.keymap.set("n", "yoo", "<Plug>(nvim-surround-normal-cur)", {
        desc = "Add a surrounding pair around the current line (normal mode)",
    })
    vim.keymap.set("n", "yO", "<Plug>(nvim-surround-normal-line)", {
        desc = "Add a surrounding pair around a motion, on new lines (normal mode)",
    })
    vim.keymap.set("n", "yOO", "<Plug>(nvim-surround-normal-cur-line)", {
        desc = "Add a surrounding pair around the current line, on new lines (normal mode)",
    })
    vim.keymap.set("x", "O", "<Plug>(nvim-surround-visual)", {
        desc = "Add a surrounding pair around a visual selection",
    })
    vim.keymap.set("x", "gO", "<Plug>(nvim-surround-visual-line)", {
        desc = "Add a surrounding pair around a visual selection, on new lines",
    })
    vim.keymap.set("n", "do", "<Plug>(nvim-surround-delete)", {
        desc = "Delete a surrounding pair",
    })
    vim.keymap.set("n", "co", "<Plug>(nvim-surround-change)", {
        desc = "Change a surrounding pair",
    })
    vim.keymap.set("n", "cO", "<Plug>(nvim-surround-change-line)", {
        desc = "Change a surrounding pair, putting replacements on new lines",
    })
	end,
}



-- keymaps = {
-- 	insert = "<C-z>o",
-- 	insert_line = "<C-z>O",
-- 	normal = "yo",
-- 	normal_cur = "yoo",
-- 	normal_line = "yO",
-- 	normal_cur_line = "yOO",
-- 	visual = "O",
-- 	visual_line = "gO",
-- 	delete = "do",
-- 	change = "co",
