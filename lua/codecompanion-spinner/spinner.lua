local log = require("codecompanion-spinner.log")

local M = {}

function M:new(chat_id, buffer)
	local object = {
		chat_id = chat_id,
		buffer = buffer,
		request_id = nil, -- ongoing request in this chat
		chat_in_buffer = true, -- buffer is displaying this chat
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
	log.debug("Spinner", object.chat_id, "created")
	return object
end

function M:_update_text()
	self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
	local last_line = vim.api.nvim_buf_line_count(self.buffer) - 1

	self:_clear_text()
	vim.api.nvim_buf_set_extmark(self.buffer, self.namespace_id, last_line, 0, {
		virt_lines = {
			{ { "" } }, -- empty line for spacing
			{ { self.spinner_symbols[self.spinner_index] .. " Processing...", "Comment" } },
		},
	})
end

function M:_clear_text()
	vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace_id, 0, -1)
end

function M:_start_timer()
	assert(not self.timer)
	local timer_fn = vim.schedule_wrap(function()
		self:_update_text()
	end)
	self.timer = vim.uv.new_timer()
	self.timer:start(0, 100, timer_fn)
	log.debug("Spinner", self.chat_id, "timer started")
end

function M:_stop_timer()
	assert(self.timer)
	self.timer:stop()
	self.timer:close()
	self.timer = nil
	log.debug("Spinner", self.chat_id, "timer stopped")
end

function M:start(request_id)
	self.request_id = request_id
	self.spinner_index = 0
	self:_start_timer()
	log.debug("Spinner", self.chat_id, "started")
end

function M:stop()
	log.debug("in stop of spinner", self.chat_id, "... chat_in_buffer:", self.chat_in_buffer)
	if self.chat_in_buffer then
		self:_clear_text()
		self:_stop_timer()
	end
	self.request_id = nil
	log.debug("Spinner", self.chat_id, "stopped")
end

function M:enable()
	self.chat_in_buffer = true
	if self.request_id then
		self:_start_timer()
	else
		-- If a request finished while the chat was hidden, there is leftover text
		self:_clear_text()
	end
	log.debug("Spinner", self.chat_id, "enabled")
end

function M:disable()
	self.chat_in_buffer = false
	if self.request_id then
		self:_stop_timer()
	end
	log.debug("Spinner", self.chat_id, "disabled")
end

return M
