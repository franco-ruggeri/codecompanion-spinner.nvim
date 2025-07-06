local Spinner = require("codecompanion-spinner.spinner")

local M = {}

local spinners = {} -- one spinner per chat
local active_spinner = nil -- spinner for the open chat

M.setup = function()
	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatCreated",
		callback = function(args)
			local chat_id = args.data.id
			assert(spinners[chat_id] == nil)
			active_spinner = Spinner:new(chat_id, args.buf)
			spinners[chat_id] = active_spinner
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatClosed",
		callback = function(args)
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
			local spinner = spinners[args.data.id]
			spinner:disable()
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestStarted",
		callback = function(args)
			assert(active_spinner)
			active_spinner:start(args.data.id)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestFinished",
		callback = function(args)
			local request_id = args.data.id
			for _, spinner in pairs(spinners) do
				if spinner.request_id == request_id then
					spinner:stop()
					return
				end
			end
			error("No spinner found for request ID: " .. request_id)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatStopped",
		callback = function(args)
			spinners[args.data.id]:stop()
		end,
	})
end

return M
