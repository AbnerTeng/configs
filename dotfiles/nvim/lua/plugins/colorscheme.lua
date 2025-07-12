return {
    -- add gruvbox
    -- { "ellisonleao/gruvbox.nvim" },
    { "rebelot/kanagawa.nvim" },
    -- Configure LazyVim to load gruvbox
    {
        "LazyVim/LazyVim",
        opts = {
            -- colorscheme = "gruvbox",
            colorscheme = "kanagawa",
        },
    },
}
