local M = {}

-- Neovim 0.10+ built-in logging (plenary.nvim is archived)
local log_level_map = {
	["debug"] = vim.log.levels.DEBUG,
	["info"] = vim.log.levels.INFO,
	["warn"] = vim.log.levels.WARN,
	["error"] = vim.log.levels.ERROR,
}

-- Default logger with plugin prefix
local logger = vim.log.new("codecompanion-spinner", log_level_map["info"] or vim.log.levels.INFO)

-- Simple log wrapper functions
function M.debug(msg, ...) 	logger.debug(msg, ...)
end

function M.info(msg, ...) 	logger.info(msg, ...)
end

function M.warn(msg, ...) 	logger.warn(msg, ...)
end

function M.error(msg, ...) 	logger.error(msg, ...)
end

-- Support varargs unpacking for compatibility
function M._extend(method, ...) 
	return ...
end

-- Make M callable like a log object
setmetatable(M, {
	__index = function(t, k)
		if type(k) == "string" and log_level_map[k] then
			return function(...) logger[k](...) end
		end
		return function(...) print("[codecompanion-spinner] " .. tostring(k) .. ": " .. ...) end
	end,
})

return M
