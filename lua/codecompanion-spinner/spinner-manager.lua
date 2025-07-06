local log = require("codecompanion-spinner.log")
local Spinner = require("codecompanion-spinner.spinner")

local M = {}

local spinners = {} -- one spinner per chat
local active_spinner = nil -- spinner for the open chat

M.setup = function()
	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatCreated",
		callback = function(args)
			for _, spinner in pairs(spinners) do
				spinner:disable()
			end

			local chat_id = args.data.id
			assert(spinners[chat_id] == nil)
			active_spinner = Spinner:new(args.buf)
			spinners[chat_id] = active_spinner
			log.debug("Spinner created for chat", chat_id)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatClosed",
		callback = function(args)
			local chat_id = args.data.id
			if spinners[chat_id] then
				spinners[chat_id]:stop()
				spinners[chat_id] = nil
				log.debug("Spinner deleted for chat", chat_id)
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatOpened",
		callback = function(args)
			-- Chats are mutually exclusively open (only one open chat at a time).
			-- So, only the spinner for the open chat must be active.
			for chat_id, spinner in pairs(spinners) do
				if chat_id == args.data.id then
					spinner:enable()
					active_spinner = spinner
					log.debug("Spinner enabled for chat", chat_id)
				else
					spinner:disable()
					log.debug("Spinner disabled for chat", chat_id)
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestStarted",
		callback = function(args)
			assert(active_spinner)
			active_spinner:start()
			log.debug("Spinner started for request", args.data.id)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = { "CodeCompanionRequestFinished", "CodeCompanionChatStopped" },
		callback = function(args)
			assert(active_spinner)
			active_spinner:stop()
			if args.match == "CodeCompanionRequestFinished" then
				log.debug("Spinner stopped for request", args.data.id)
			else
				log.debug("Spinner stopped in chat", args.data.id)
			end
		end,
	})
end

return M
