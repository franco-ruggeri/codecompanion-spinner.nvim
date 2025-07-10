# 🌀 CodeCompanion Spinner

## 📖 Overview

Inline spinner for
[CodeCompanion](https://github.com/olimorris/codecompanion.nvim) in Neovim.

This plugin adds an animated spinner in the CodeCompanion chat while AI is
processing a request, giving clear feedback to the user.

![demo-spinner](https://github.com/user-attachments/assets/66191a4e-8bab-4c37-88f6-f208c9f387ea)

Note the *"Processing..."* virtual text while AI is generating the response.

## ✨ Features

- 🌀 Animated spinner in CodeCompanion chat during AI processing.
- 🗂️ Supports multiple chats with concurrent active requests (each gets its
  own spinner).
- ⚙️ Zero configuration.

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

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

## 🙏 Acknowledgements

Thanks [yuhua99](https://github.com/yuhua99) for providing the basic [spinner
logic](https://github.com/olimorris/codecompanion.nvim/discussions/640#discussioncomment-12866279).
