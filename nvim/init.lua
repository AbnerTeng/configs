require('options')
require('keymaps')
require('plugins')
require('colorscheme')
require('lsp')
require("toggleterm-config")
require("whichkey")

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- OR setup with some options
require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        width = 30,
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
    },
})

-- local function open_nvim_tree()
--     require("nvim-tree.api").tree.open()
-- end

-- vim.api.nvim_create_autocmd(
--     { "VimEnter" },
--     { callback = open_nvim_tree }
-- )

-- for telescope

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- for lualine

require("lualine").setup {
    options = {
        icons_enabled = true,
        theme = "catppuccin",
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
            statusline = {},
            winbar = {}
        },
        always_divide_middle = true,
        global_status = true,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {'hostname'},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    extensions = {'fugitive'}
}

-- for catppuccin

require("catppuccin").setup({
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "mocha",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = true, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = true, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        bufferline = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        telescope = {
            enabled = true,
            theme = "dropdown",
        },
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = { "italic" },
                hints = { "italic"},
                warnings = { "italic" },
                information = { "italic" },
                ok = { "italic" },
            },
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                warnings = { "underline" },
                information = { "underline" },
                ok = { "underline" },
            },
            inlay_hints = {
                background = true,
            },
        },
    },
})

-- setup must be called before loading
-- vim.cmd.colorscheme "catppuccin"

vim.opt.background = "dark" -- set this to dark or light
vim.cmd.colorscheme "oxocarbon"

-- for mininvim

require('mini.starter').setup{
    autoopen = true,

}
require('mini.icons').setup{
    style = "glyph"
}
--bufferline

vim.opt.termguicolors = true
local bufferline = require("bufferline")
bufferline.setup{
    options = {
        mode = "buffers",
        style_preset = bufferline.style_preset.default,
        themeable = true,
        numbers = function(opts)
            return string.format('%s|%s', opts.id, opts.raise(opts.ordinal))
        end,
        indicator = {
            icon = "▎",
            style = 'icon',
        },
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "center",
                separator = true,
            }
        },
        separator_style = "padded_slant",
        view = "multiwindow",
        hover = {
            enabled = true,
            delay = 200,
            reveal = {'close'}
        },
        diagnostics = "nvim_lsp",
        highlight = {
            fill = {
                bg = {
                    attribute = "fg",
                    highlight = "Pmenu"
                },
            }
        },
    }
}

-- copilot setup --
-- vim.g.copilot_no_tab_map = true
-- vim.api.nvim_set_keymap('i', '<TAB>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
