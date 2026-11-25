
-- [[ Configure Treesitter (main branch) ]]

local languages = {
  'go',
  'lua',
  'python',
  'rust',
  'typescript',
  'regex',
  'bash',
  'markdown',
  'markdown_inline',
  'kdl',
  'sql',
  'c',
  'cpp',
  'javascript',
  'tsx',
}

-- Configure the new Treesitter API
require('nvim-treesitter').setup()

-- Install parsers and queries
require('nvim-treesitter').install(languages)

-- Enable Treesitter features for supported filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'go',
    'lua',
    'python',
    'rust',
    'typescript',
    'sh',
    'bash',
    'markdown',
    'kdl',
    'sql',
    'c',
    'cpp',
    'javascript',
    'typescriptreact',
  },
  callback = function(args)
    -- Syntax highlighting
    pcall(vim.treesitter.start, args.buf)

    -- Folding (disabled for Python, as in your old config)
    if vim.bo[args.buf].filetype ~= 'python' then
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end

    -- Treesitter indentation (experimental)
    vim.bo[args.buf].indentexpr =
      "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

