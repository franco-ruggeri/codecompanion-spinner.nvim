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

			local spinner = spinners[args.data.id]

			-- When a new chat is created, this event is triggered but no spinner is
			-- available yet. After this, the CodeCompanionChatCreated event will be
			-- triggered. The spinner is created there.
			if not spinner then
				return
			end

			active_spinner = spinner
			active_spinner:enable()
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatHidden",
		callback = function(args)
			log.debug("CodeCompanionChatHidden")
			local spinner = spinners[args.data.id]
			spinner:disable()
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestStarted",
		callback = function(args)
			log.debug("CodeCompanionRequestStarted")
			assert(active_spinner)
			active_spinner:start(args.data.id)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestFinished",
		callback = function(args)
			log.debug("CodeCompanionRequestFinished")

			-- Search for the spinner is handling the request.
			-- Note: If the chat was stopped, the spinner was deleted.
			-- In that case, no spinner will be found.
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
