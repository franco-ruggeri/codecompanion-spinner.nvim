local log = require("codecompanion-spinner.log")

local M = {}

function M:new(buffer)
	local object = {
		buffer = buffer,
		enabled = true,
		timer = nil,
		namespace_id = vim.api.nvim_create_namespace("CodeCompanionSpinner"),
		spinner_index = nil,
		spinner_symbols = {
			"⠋",
			"⠙",
			"⠹",
			"⠸",
			"⠼",
			"⠴",
			"⠦",
			"⠧",
			"⠇",
			"⠏",
		},
	}
	self.__index = self
	setmetatable(object, self)
	log.debug("Spinner created")
	return object
end

function M:update()
	vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace_id, 0, -1)
	self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
	local last_line = vim.api.nvim_buf_line_count(self.buffer) - 1
	vim.api.nvim_buf_set_extmark(self.buffer, self.namespace_id, last_line, 0, {
		virt_lines = {
			{ { "" } }, -- empty line for spacing
			{ { self.spinner_symbols[self.spinner_index] .. " Processing...", "Comment" } },
		},
	})
	log.debug("Spinner updated virtual text with symbol: ", self.spinner_symbols[self.spinner_index])
end

function M:_start_timer()
	assert(not self.timer)
	local timer_fn = vim.schedule_wrap(function()
		self:update()
	end)
	self.timer = vim.uv.new_timer()
	self.timer:start(0, 100, timer_fn)
	log.debug("Spinner timer started")
end

function M:_stop_timer()
	assert(self.timer)
	self.timer:stop()
	self.timer:close()
	self.timer = nil
	log.debug("Spinner timer stopped")
end

function M:_request_in_progress()
	return self.timer ~= nil
end

function M:start()
	self.spinner_index = 0
	self:_start_timer()
	log.debug("Spinner started")
end

function M:stop()
	if self:_request_in_progress() then
		self:_stop_timer()
		vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace_id, 0, -1)
	end
	log.debug("Spinner stopped")
end

function M:enable()
	self.enabled = true
	if self:_request_in_progress() then
		self:_start_timer()
	end
	log.debug("Spinner enabled")
end

function M:disable()
	self.enabled = false
	if self:_request_in_progress() then
		self:_stop_timer()
	end
	log.debug("Spinner disabled")
end

return M
