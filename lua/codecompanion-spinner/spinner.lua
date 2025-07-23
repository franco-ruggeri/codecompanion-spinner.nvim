local log = require("codecompanion-spinner.log")

local M = {}

function M:new(chat_id, buffer)
	local object = {
		chat_id = chat_id,
		buffer = buffer,
		started = false, -- whether there is an active request in the chat
		enabled = false, -- whether the chat buffer is displaying the chat
		timer = nil,
		namespace_id = vim.api.nvim_create_namespace("CodeCompanionSpinner"),
		spinner_index = 0,
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
		return
	end
	self.timer:stop()
	self.timer:close()
	self.timer = nil
	log.debug("Spinner", self.chat_id, "timer stopped")
end

function M:_update_state()
	-- The spinner can have 4 states

	-- 1. <enabled=true, started=true>
	--  The chat controlled by the spinner is displayed in the chat buffer and has an active request.
	--  In this state, the spinner should run and print the virtual text.
	if self.enabled and self.started then
		self:_start_timer()

	-- 2. <enabled=true, started=false>:
	--  The chat controlled by the spinner is displayed in the chat buffer, but there is no active request.
	--  In this state, the spinner should ensure that no virtual text is shown.
	elseif self.enabled and not self.started then
		self:_stop_timer()
		self:_clear_text()

	-- 3/4. <enabled=false, *>
	--  The chat controlled by the spinner is not displayed in the chat buffer.
	--  In these states, the spinner should not touch the chat buffer, which is controlled by another spinner.
	else
		self:_stop_timer()
	end

	log.debug(
		"Spinner",
		self.chat_id,
		"state updated:",
		"enabled=" .. tostring(self.enabled),
		"started=" .. tostring(self.started)
	)
end

function M:start()
	self.started = true
	self:_update_state()
end

function M:stop()
	self.started = false
	self:_update_state()
end

function M:enable()
	self.enabled = true
	self:_update_state()
end

function M:disable()
	self.enabled = false
	self:_update_state()
end

return M
