vim.cmd( [[
augroup MyColors
autocmd!
autocmd ColorScheme * highlight LeapBackdrop  guibg=#1c1c1c
autocmd ColorScheme * highlight LeapLabelPrimary guifg=#101010 guibg=#fda697
autocmd ColorScheme * highlight LeapLabelSecondary guibg=#a6c8c0 guifg=black
autocmd ColorScheme * highlight LeapMatch guibg=#fca972 guifg=black
augroup end
]] )

-- vim.api.nvim_set_hl( 0, 'LeapBackdrop', {
--     bg = '#1c1c1c',
--  } )

-- vim.api.nvim_set_hl( 0, 'LeapLabelPrimary', {
--     fg = '#101010',
--     bg = '#fda697',
--  } )

-- vim.api.nvim_set_hl( 0, 'LeapLabelSecondary', {
--     bg = '#a6c8c0',
--     fg = 'black',
--  } )

-- vim.api.nvim_set_hl( 0, 'LeapMatch', {
--     bg = '#fca972',
--     fg = 'black',
--  } )

