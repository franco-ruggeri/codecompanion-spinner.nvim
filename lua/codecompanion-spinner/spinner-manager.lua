local log = require("codecompanion-spinner.log")
local Spinner = require("codecompanion-spinner.spinner")

local M = {}

local spinners = {} -- one spinner per chat
local active_spinner = nil -- spinner for the open chat

M.setup = function()
	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatCreated",
		callback = function(args)
			log.debug("CodeCompanionChatCreated")
			local chat_id = args.data.id
			assert(spinners[chat_id] == nil)
			active_spinner = Spinner:new(chat_id, args.buf)
			spinners[chat_id] = active_spinner
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatClosed",
		callback = function(args)
			log.debug("CodeCompanionChatClosed")
			local chat_id = args.data.id
			if spinners[chat_id] then
				spinners[chat_id]:stop()
				spinners[chat_id] = nil
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatOpened",
		callback = function(args)
			log.debug("CodeCompanionChatOpened")

			-- When a new chat is created, this event is triggered but no spinner is
			-- available yet. After this, the CodeCompanionChatCreated event will be
			-- triggered, which creates the spinner. Here, we need to check if the
			-- spinner exists.
			local spinner = spinners[args.data.id]
			if spinner then
				active_spinner = spinner
				active_spinner:enable()
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatHidden",
		callback = function(args)
			log.debug("CodeCompanionChatHidden")
			local spinner = spinners[args.data.id]
			if spinner then
				spinner:disable()
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestStarted",
		callback = function(args)
			log.debug("CodeCompanionRequestStarted")
			-- The request might be inline, without an active chat.
			-- In that case, we don't have an active spinner.
			if active_spinner then
				active_spinner:start(args.data.id)
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestFinished",
		callback = function(args)
			log.debug("CodeCompanionRequestFinished")

			-- Search for the spinner is handling the request.
			-- Note: The spinner will not found in some cases:
			-- * When the chat was stopped, the spinner was deleted.
			-- * When the request was inline.
			local request_id = args.data.id
			for _, spinner in pairs(spinners) do
				if spinner.request_id == request_id then
					spinner:stop()
					break
				end
			end
		end,
	})
end

return M
