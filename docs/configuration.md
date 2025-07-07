# Configuration Guide

## Overview

codecompanion-spinner.nvim supports different visual feedback styles for CodeCompanion requests. You can choose between custom spinners, fidget integration, or disable the functionality entirely.

## Configuration Options

### `style` (string)

Controls which spinner style to use. Must be one of:

- **`"spinner"`** (default): Custom animated spinner in chat buffers
- **`"fidget"`**: Uses fidget.nvim for progress notifications  
- **`"none"`**: Disables all spinner functionality

### `log_level` (string)

Controls logging verbosity. Options:

- `"trace"`: Most verbose, shows all debug information
- `"debug"`: Debug information for troubleshooting
- `"info"`: General information messages (default)
- `"warn"`: Warning messages only
- `"error"`: Error messages only

## Style Comparison

### Spinner Style (`"spinner"`)

**Pros:**
- ✅ No external dependencies
- ✅ Integrated directly into chat buffers
- ✅ Consistent with CodeCompanion UI
- ✅ Shows per-chat progress

**Cons:**
- ❌ Only visible in chat buffers
- ❌ Less system-wide visibility

**Best for:** Users who prefer minimal dependencies and want spinner feedback directly in the chat interface.

### Fidget Style (`"fidget"`)

**Pros:**
- ✅ System-wide progress notifications
- ✅ Consistent with other LSP progress indicators
- ✅ Shows detailed adapter/model information
- ✅ Better for background requests

**Cons:**
- ❌ Requires fidget.nvim dependency
- ❌ Less integrated with chat UI

**Best for:** Users who already use fidget.nvim for LSP progress and want consistent progress indicators across their setup.

### None Style (`"none"`)

**Pros:**
- ✅ No visual distractions
- ✅ Minimal resource usage
- ✅ Clean interface

**Cons:**
- ❌ No visual feedback for request progress
- ❌ Harder to know when requests are active

**Best for:** Users who prefer minimal UI and don't need progress indicators.

## Example Configurations

### Basic Setup (Default)
```lua
require("codecompanion-spinner").setup()
-- Uses default: style = "spinner", log_level = "info"
```

### Fidget Integration
```lua
require("codecompanion-spinner").setup({
    style = "fidget",
    log_level = "info",
})
```

### Disabled Spinner
```lua
require("codecompanion-spinner").setup({
    style = "none",
    log_level = "warn", -- Reduce logging when disabled
})
```

### Dynamic Configuration
```lua
-- Choose style based on available plugins
local has_fidget = pcall(require, "fidget")
require("codecompanion-spinner").setup({
    style = has_fidget and "fidget" or "spinner",
    log_level = "info",
})
```

## Runtime Style Switching

You can change the style at runtime by calling setup again:

```lua
-- Switch to fidget style
require("codecompanion-spinner").setup({ style = "fidget" })

-- Switch to spinner style  
require("codecompanion-spinner").setup({ style = "spinner" })

-- Disable spinner
require("codecompanion-spinner").setup({ style = "none" })
```

## Troubleshooting

### Fidget Style Not Working

1. Ensure fidget.nvim is installed and configured
2. Check that fidget.nvim is loaded before codecompanion-spinner
3. Enable debug logging: `log_level = "debug"`

### Spinner Not Showing

1. Ensure CodeCompanion is properly configured
2. Check that the chat buffer is active
3. Verify that requests are being made to the LLM

### Performance Issues

1. Try switching to `"none"` style to disable all spinners
2. Reduce log level to `"warn"` or `"error"`
3. Check if other plugins are conflicting

## Dependencies

- **All styles**: `codecompanion.nvim`, `plenary.nvim`
- **Fidget style**: Additionally requires `fidget.nvim`
- **Spinner style**: No additional dependencies
- **None style**: No additional dependencies