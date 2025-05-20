local M = {}

function M.setup()
  -- UFO setup
  require("ufo").setup({
    provider_selector = function(_, filetype, _)
      return {'treesitter', 'indent'}
    end
  })

  -- Keybindings
  vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
  vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
end

return M

