# 🌀 CodeCompanion Spinner

## 📖 Overview

Inline spinner for
[CodeCompanion](https://github.com/olimorris/codecompanion.nvim) in Neovim.

This plugin adds an animated spinner in the CodeCompanion chat while AI is
processing a request, giving clear feedback to the user.

![demo-spinner](https://github.com/user-attachments/assets/66191a4e-8bab-4c37-88f6-f208c9f387ea)

Note the _"Processing..."_ virtual text while AI is generating the response.

## ✨ Features

own spinner).

- 📊 Fidget.nvim integration for progress notifications (optional).

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "franco-ruggeri/codecompanion-spinner.nvim",
    dependencies = {
        "olimorris/codecompanion.nvim",
        "nvim-lua/plenary.nvim",
        "j-hui/fidget.nvim", -- Optional: for fidget integration
    },
     opts = {
         log_level = "info",
         style = "spinner", -- "spinner", "fidget", or "none"
     }
}
```

If you use another plugin manager, make sure to call:

```lua
require("codecompanion-spinner").setup()
```

## ⚙️ Configuration

```lua
require("codecompanion-spinner").setup({
    -- Log level for debugging
    log_level = "info", -- "trace", "debug", "info", "warn", "error"

    -- Spinner style
    style = "spinner", -- "spinner", "fidget", or "none"
})
```

The plugin supports different spinner styles:

- **"spinner"** (default): Custom animated spinner in chat buffers
- **"fidget"**: Uses fidget.nvim for progress notifications (requires fidget.nvim)
- **"none"**: Disables all spinner functionality

Only one style can be active at a time.

## 🙏 Acknowledgements

Thanks [yuhua99](https://github.com/yuhua99) for providing the basic [spinner
logic](https://github.com/olimorris/codecompanion.nvim/discussions/640#discussioncomment-12866279).
