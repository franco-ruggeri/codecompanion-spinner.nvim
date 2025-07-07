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
			if not args or not args.data or not args.data.id then
				log.warn("Invalid args in CodeCompanionChatCreated")
				return
			end

			local chat_id = args.data.id
			if spinners[chat_id] then
				log.warn("Spinner already exists for chat", chat_id)
				spinners[chat_id]:stop()
			end

			active_spinner = Spinner:new(chat_id, args.buf)
			if active_spinner then
				spinners[chat_id] = active_spinner
			else
				log.error("Failed to create spinner for chat", chat_id)
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatClosed",
		callback = function(args)
			log.debug("CodeCompanionChatClosed")
			if not args or not args.data or not args.data.id then
				log.warn("Invalid args in CodeCompanionChatClosed")
				return
			end

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

			if not args or not args.data or not args.data.id then
				log.warn("Invalid args in CodeCompanionChatOpened")
				return
			end

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
			if not args or not args.data or not args.data.id then
				log.warn("Invalid args in CodeCompanionChatHidden")
				return
			end

			local spinner = spinners[args.data.id]
			if spinner then
				spinner:disable()
			else
				log.warn("No spinner found for chat", args.data.id)
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestStarted",
		callback = function(args)
			log.debug("CodeCompanionRequestStarted")
			if not args or not args.data or not args.data.id then
				log.warn("Invalid args in CodeCompanionRequestStarted")
				return
			end

			if not active_spinner then
				log.warn("No active spinner available")
				return
			end

			active_spinner:start(args.data.id)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestFinished",
		callback = function(args)
			log.debug("CodeCompanionRequestFinished")

			if not args or not args.data or not args.data.id then
				log.warn("Invalid args in CodeCompanionRequestFinished")
				return
			end

			-- Search for the spinner is handling the request.
			-- Note: If the chat was stopped, the spinner was deleted.
			-- In that case, no spinner will be found.
			local request_id = args.data.id
			for _, spinner in pairs(spinners) do
				if spinner and spinner.request_id == request_id then
					spinner:stop()
					break
				end
			end
		end,
	})
end

return M
