-- Set highlight on search
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false

vim.opt.smartindent = true

vim.opt.wrap = true

USER = os.getenv("USER")
local curr_group = vim.fn.system("id -ng 2> /dev/null | tr -d '\n'")

SWAPDIR = "/home/" .. USER .. "/.vim/swapdir//"
BACKUPDIR = "/home/" .. USER .. "/.nvim/backupdir//"
UNDODIR = "/home/" .. USER .. "/.vim/undodir//"

if vim.fn.isdirectory(SWAPDIR) == 0 then
       vim.fn.mkdir(SWAPDIR, "p", "0o700")
end

if vim.fn.isdirectory(BACKUPDIR) == 0 then
       vim.fn.mkdir(BACKUPDIR, "p", "0o700")
end

if vim.fn.isdirectory(UNDODIR) == 0 then
       vim.fn.mkdir(UNDODIR, "p", "0o700")
end

-- Enable swap, backup, and persistant undo
vim.opt.directory = SWAPDIR
vim.opt.backupdir = BACKUPDIR
vim.opt.undodir = UNDODIR
vim.opt.swapfile = true
vim.opt.backup = true
vim.opt.undofile = true

-- Append backup files with timestamp
vim.api.nvim_create_autocmd("BufWritePre", {
       callback = function()
               local extension = "~" .. vim.fn.strftime("%Y-%m-%d-%H%M%S")
               vim.o.backupext = extension
       end,
})


vim.opt.scrolloff = 8
-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- Disable mouse mode
vim.o.mouse = ''

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set colorscheme
--vim.cmd [[colorscheme onedark]]
vim.cmd.colorscheme "catppuccin"

--vim.cmd()
vim.opt.clipboard = 'unnamedplus'

-- Set completeopt to have a better completion experience

vim.o.completeopt = 'menuone,noselect'

-- Concealer for Neorg
vim.o.conceallevel=2

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- fold setup
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.fillchars:append("fold: ")
vim.opt.foldlevelstart = 99

-- vim.o.foldcolumn = '1' -- '0' is not bad
-- vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
-- vim.o.foldlevelstart = 99
-- vim.o.foldenable = true
-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]



