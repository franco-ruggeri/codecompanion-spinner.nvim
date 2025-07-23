local log = require("codecompanion-spinner.log")

local M = {}

function M:new(chat_id, buffer)
	local object = {
		chat_id = chat_id,
		buffer = buffer,
		started = false, -- whether there is an active request in the chat
		enabled = false, -- whether the chat buffer is displaying this chat
		timer = nil,
		namespace_id = vim.api.nvim_create_namespace("CodeCompanionSpinner"),
		spinner_index = nil,
		spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
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
	if vim.api.nvim_buf_is_valid(self.buffer) then -- if not closed already
		vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace_id, 0, -1)
	end
end

function M:_start_timer()
	if self.timer then
		log.debug("Spinner", self.chat_id, "timer already started")
		return
	end

	local timer_fn = vim.schedule_wrap(function()
		self:_update_text()
	end)
	self.timer = vim.uv.new_timer()
	self.timer:start(0, 100, timer_fn)
	log.debug("Spinner", self.chat_id, "timer started")
end

function M:_stop_timer()
	if not self.timer then
		log.debug("Spinner", self.chat_id, "timer already stopped")
		return
	end

	self.timer:stop()
	self.timer:close()
	self.timer = nil
	log.debug("Spinner", self.chat_id, "timer stopped")
end

function M:start()
	if self.started then
		log.debug("Spinner", self.chat_id, "already started")
		return
	end

	self.spinner_index = 0
	self:_start_timer()
	self.started = true
	log.debug("Spinner", self.chat_id, "started")
end

function M:stop()
	if not self.started then
		log.debug("Spinner", self.chat_id, "already stopped")
		return
	end

	if self.enabled then
		self:_stop_timer()
		self:_clear_text()
	end
	self.started = false
	log.debug("Spinner", self.chat_id, "stopped")
end

function M:enable()
	if self.enabled then
		log.debug("Spinner", self.chat_id, "already enabled")
		return
	end

	if self.started then
		self:_start_timer()
	else
		-- If the request finished while the chat was hidden, there is leftover text
		self:_clear_text()
	end
	self.enabled = true
	log.debug("Spinner", self.chat_id, "enabled")
end

function M:disable()
	if not self.enabled then
		log.debug("Spinner", self.chat_id, "already disabled")
		return
	end

	if self.started then
		self:_stop_timer()
	end
	self.enabled = false
	log.debug("Spinner", self.chat_id, "disabled")
end

return M
