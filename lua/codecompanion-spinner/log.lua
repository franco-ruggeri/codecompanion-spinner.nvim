local M = {}

M.setup = function(log_level)
	local ok, plenary_log = pcall(require, "plenary.log")
	if not ok then
		-- If plenary is not available, provide a basic logging implementation
		M.trace = function(...) end
		M.debug = function(...) end
		M.info = function(...)
			print("[INFO]", ...)
		end
		M.warn = function(...)
			print("[WARN]", ...)
		end
		M.error = function(...)
			print("[ERROR]", ...)
		end
		return
	end

	local log = plenary_log.new({
		plugin = "codecompanion-spinner",
		level = log_level or "info",
	})

	setmetatable(M, { __index = log })
end

-- Provide default empty functions to prevent errors before setup
M.trace = function(...) end
M.debug = function(...) end
M.info = function(...) end
M.warn = function(...) end
M.error = function(...) end
return M
