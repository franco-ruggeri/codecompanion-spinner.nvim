# 🌀 CodeCompanion Spinner

> ⚠️ **Note**: This plugin no longer requires `plenary.nvim` dependency due to Neovim 0.10+ built-in logging support.

## 📖 Overview

Inline spinner for
[CodeCompanion](https://github.com/olimorris/codecompanion.nvim) in Neovim.

This plugin adds an animated spinner in the CodeCompanion chat while AI is
processing a request, giving clear feedback to the user.

![demo-spinner](https://github.com/user-attachments/assets/66191a4e-8bab-8869-a67e-b115-d28e3084c473)

Note the *"Processing..."* virtual text while AI is generating the response.

## ✨ Features

- 🌀 Animated spinner in CodeCompanion chat during AI processing.
- 🗂️ Supports multiple chats with concurrent active requests (each gets its
  own spinner).
- ⚙️ Zero configuration.
- 🚫 **No `plenary.nvim` dependency required** (uses Neovim built-in logging).

## 📦 Installation

Add the inline spinner to your CodeCompanion setup as follows:

```lua
require("codecompanion").setup({
    -- ... other codecompanion setup ...
    extensions = {
        spinner = {},
    },
})
```

<details>
<summary>Example using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a>:</summary>

```lua
{
    "olimorris/codecompanion.nvim",
    dependencies = {
        "franco-ruggeri/codecompanion-spinner.nvim",
        -- plenary.nvim is no longer required
    },
    opts = {
        -- ... other codecompanion setup ...
        extensions = {
            spinner = {},
        },
    },
}
```

</details>

## 🧪 Compatibility

- ✅ **Neovim 0.10+**: Uses built-in `vim.log` API
- ⚠️ **Neovim <0.10**: May require `plenary.nvim` fallback (deprecated)

## 🙏 Acknowledgements

Thanks [yuhua99](https://github.com/yuhua99) for providing the basic [spinner
logic](https://github.com/olimorris/codecompanion.nvim/discussions/640#discussioncomment-12866279).

---

## 🔄 Migration Note

This plugin has been updated to no longer depend on `plenary.nvim`, which is being archived.
If you're upgrading from an older version, you can remove `plenary.nvim` from your dependencies.
