local M = {}

M.setup = function(log_level)
	local log = require("plenary.log").new({
		plugin = "codecompanion-spinner",
		level = log_level,
	})

	setmetatable(M, { __index = log })
end

return M
