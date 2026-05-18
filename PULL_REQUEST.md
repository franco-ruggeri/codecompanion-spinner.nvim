# Pull Request: Migrate from plenary.nvim to Neovim built-in logging

## Description

This PR fixes issue #10 by migrating the plugin from `plenary.nvim` (which is being archived) to Neovim's built-in logging API.

## Changes

- **`lua/codecompanion-spinner/log.lua`**: Replaced `plenary.log` dependency with Neovim's `vim.log` API
- **`lua/codecompanion-spinner/init.lua`**: Removed `setup()` function that was configuring plenary
- **`README.md`**: Updated to:
  - Remove `plenary.nvim` from required dependencies
  - Add compatibility notes for Neovim 0.10+
  - Document the migration

## Compatibility

- ✅ Neovim 0.10+ (uses built-in `vim.log`)
- ⚠️ Neovim <0.10 (may require `plenary.nvim` fallback)

## Testing

Tested on:
- Neovim 0.10.x with `lazy.nvim`
- CodeCompanion with spinner extension

## Migration Guide

### Before (requires plenary.nvim):
```lua
{
    "olimorris/codecompanion.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim", version = false },
        "franco-ruggeri/codecompanion-spinner.nvim",
    },
    opts = {
        extensions = {
            spinner = {},
        },
    },
}
```

### After (no plenary.nvim needed):
```lua
{
    "olimorris/codecompanion.nvim",
    dependencies = {
        -- plenary.nvim no longer required
        "franco-ruggeri/codecompanion-spinner.nvim",
    },
    opts = {
        extensions = {
            spinner = {},
        },
    },
}
```
