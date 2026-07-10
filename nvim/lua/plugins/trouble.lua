local map = vim.keymap.set

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { silent = true })
map("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", { silent = true })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { silent = true })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { silent = true })
map("n", "gR", "<cmd>Trouble lsp_references toggle<CR>", { silent = true })

-- Diagnostic signs
-- https://github.com/folke/trouble.nvim/issues/52
local signs = {
    Error = " ",
    Warning = " ",
    Hint = " ",
    Information = " "
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

