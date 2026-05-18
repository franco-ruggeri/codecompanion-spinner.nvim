local M = {}

M.level = nil

function M.log(level, msg)
	if level < M.level then
		return
	end
	vim.notify("[codecompanion-spinner] " .. msg, level)
end

function M.setup(log_level)
	M.level = log_level
end

function M.debug(msg) M.log(vim.log.levels.DEBUG, msg) end
function M.info(msg) M.log(vim.log.levels.INFO, msg) end
function M.warn(msg) M.log(vim.log.levels.WARN, msg) end
function M.error(msg) M.log(vim.log.levels.ERROR, msg) end

return M
