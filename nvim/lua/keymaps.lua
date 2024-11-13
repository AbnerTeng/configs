-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
    expr = true,         -- allow to use expression mapping
    replace_keycodes = true, -- allow key codes to be replaced
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Open NvimTree --
vim.keymap.set(
    'n',
    '<leader>t',
    ':NvimTreeOpen<CR>',
    {
        noremap = true,
        silent = true
    }
)

-- Bufferline settings --
vim.keymap.set('n', ']b', ':BufferLineCycleNext<CR>')
vim.keymap.set('n', '[b', ':BufferLineCyclePrev<CR>')


-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-----------------
-- Insert mode --
-----------------

vim.keymap.set('i', '<Tab>', function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "    "
end, opts)

vim.keymap.set('i', '<S-Tab>', function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-h><C-h><C-h><C-h>"
end, opts)
