local codecompanion_spinner = require("codecompanion-spinner")

---@class CodeCompanion.Extension
---@field setup fun(opts: table) Function called when extension is loaded
---@field exports? table Functions exposed via codecompanion.extensions.your_extension
local M = {}

function M.setup(opts)
	codecompanion_spinner.setup(opts)
end

return M
