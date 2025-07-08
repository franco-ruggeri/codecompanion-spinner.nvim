local log = require("codecompanion-spinner.log")

local M = {}

function M:new(chat_id, buffer)
	if not chat_id or not buffer then
		log.error("Invalid parameters for Spinner:new - chat_id and buffer are required")
		return nil
	end

	if not vim.api.nvim_buf_is_valid(buffer) then
		log.error("Invalid buffer provided to Spinner:new")
		return nil
	end

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
	if not self.buffer or not vim.api.nvim_buf_is_valid(self.buffer) then
		log.warn("Invalid buffer in _update_text")
		return
	end

	self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
	local last_line = vim.api.nvim_buf_line_count(self.buffer) - 1

	self:_clear_text()

	local ok, err = pcall(vim.api.nvim_buf_set_extmark, self.buffer, self.namespace_id, last_line, 0, {
		virt_lines = {
			{ { "" } }, -- empty line for spacing
			{ { self.spinner_symbols[self.spinner_index] .. " Processing...", "Comment" } },
		},
	})

	if not ok then
		log.warn("Failed to set extmark:", err)
	end
end

function M:_clear_text()
	if vim.api.nvim_buf_is_valid(self.buffer) then -- if not closed already
		vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace_id, 0, -1)
	end
end

function M:_start_timer()
	if self.timer then
		log.warn("Timer already exists, stopping previous timer")
		self:_stop_timer()
	end

	local timer_fn = vim.schedule_wrap(function()
		self:_update_text()
	end)
	self.timer = vim.uv.new_timer()
	if self.timer then
		self.timer:start(0, 100, timer_fn)
	else
		log.error("Failed to create timer")
		return
	end
	log.debug("Spinner", self.chat_id, "timer started")
end

function M:_stop_timer()
	if not self.timer then
		log.debug("No timer to stop")
		return
	end

	-- Check if timer is still valid before stopping
	local ok1, err1 = pcall(function() 
		if self.timer and self.timer:is_active() then
			self.timer:stop() 
		end
	end)
	if not ok1 then
		log.warn("Failed to stop timer:", err1)
	end

	-- Check if timer is still valid before closing
	local ok2, err2 = pcall(function() 
		if self.timer and not self.timer:is_closing() then
			self.timer:close() 
		end
	end)
	if not ok2 then
		log.warn("Failed to close timer:", err2)
	end

	self.timer = nil
	log.debug("Spinner", self.chat_id, "timer stopped")
end

function M:start(request_id)
	if not request_id then
		log.warn("No request_id provided to start")
		return
	end

	self.request_id = request_id
	self.spinner_index = 0
	self:_start_timer()
	log.debug("Spinner", self.chat_id, "started")
end

function M:stop()
	if self.chat_in_buffer then
		self:_clear_text()
	end
	-- Always attempt to stop timer if it exists, regardless of chat_in_buffer state
	if self.timer then
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
	-- Stop timer if it's running, regardless of request_id state
	if self.timer then
		self:_stop_timer()
	end
	log.debug("Spinner", self.chat_id, "disabled")
end

return M
