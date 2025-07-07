local M = {}

M.spinner_manager = require("codecompanion-spinner.spinner-manager")
M.fidget_spinner = require("codecompanion-spinner.fidget-spinner")
M.log = require("codecompanion-spinner.log")

-- Valid spinner styles
M.STYLES = {
	SPINNER = "spinner",
	FIDGET = "fidget",
	NONE = "none",
}
M.opts = {
	log_level = "info",
	style = M.STYLES.SPINNER, -- Default to spinner
}
local function validate_style(style)
	if not style then
		return false
	end
	for _, valid_style in pairs(M.STYLES) do
		if style == valid_style then
			return true
		end
	end
	return false
end

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

	-- Ensure logging is initialized first
	M.log.setup(M.opts.log_level)

	-- Validate style
	if not validate_style(M.opts.style) then
		M.log.warn("Invalid style '" .. tostring(M.opts.style) .. "', using default '" .. M.STYLES.SPINNER .. "'")
		M.opts.style = M.STYLES.SPINNER
	end

	-- Enable corresponding functionality based on style configuration
	if M.opts.style == M.STYLES.SPINNER then
		local ok, err = pcall(M.spinner_manager.setup)
		if not ok then
			M.log.error("Failed to setup spinner manager:", err)
		end
	elseif M.opts.style == M.STYLES.FIDGET then
		local ok, err = pcall(M.fidget_spinner.setup)
		if not ok then
			M.log.error("Failed to setup fidget spinner:", err)
		end
	elseif M.opts.style == M.STYLES.NONE then
		-- Do not enable any spinner
		M.log.info("Spinner disabled")
		return
	end
end

return M
