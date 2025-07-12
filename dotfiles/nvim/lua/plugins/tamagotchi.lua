return {
    "AbnerTeng/vibe-coding-test",
    -- For lazy-loading (recommended):
    cmd = { "TamagotchiSetup", "TamagotchiFeed", "TamagotchiPlay", "TamagotchiStatus" },

    -- Configure the plugin (optional):
    opts = {
        default_name = "MyNeoFriend", -- Set your pet's default name
        pet_ascii_art = { -- Default appearance
            "  /\\_/\\ ",
            " (='.'=)",
            ' (")_(")',
        },
        pet_window_length = 7,
        pet_window_width = 50,
    },

    -- Ensure LazyVim calls the plugin's setup function with your options:
    -- `config = true` tells LazyVim to call `require('tamagotchi').setup(opts)`
    config = true,
    -- Alternatively, for more complex setup:
    -- config = function(plugin, opts)
    --   require('tamagotchi').setup(opts)
    --   -- Additional setup steps here
    -- end,

    -- Or, to load on startup without specific opts handling by LazyVim (setup will use defaults):
    -- event = "VeryLazy",
}
