local ok, theme = pcall(dofile, vim.fn.expand("~/.config/nvim/current_theme.lua"))
vim.cmd.colorscheme(ok and theme or "coal")
