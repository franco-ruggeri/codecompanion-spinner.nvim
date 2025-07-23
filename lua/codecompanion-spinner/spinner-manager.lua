local log = require("codecompanion-spinner.log")
local Spinner = require("codecompanion-spinner.spinner")

local M = {}

local spinners = {} -- one spinner per chat

M.setup = function()
	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatCreated",
		callback = function(args)
			log.debug(args.match)

			local chat_id = args.data.id
			if spinners[chat_id] then
				log.debug("Spinner", chat_id, "already exists")
				return
			end

			local spinner = Spinner:new(chat_id, args.buf)
			spinner:enable()
			spinners[chat_id] = spinner
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatClosed",
		callback = function(args)
			log.debug("CodeCompanionChatClosed")
			local chat_id = args.data.id
			local spinner = spinners[chat_id]
			if not spinner then
				log.debug("Spinner", chat_id, "not found")
				return
			end
			spinner:stop()
			spinners[chat_id] = nil
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatOpened",
		callback = function(args)
			log.debug(args.match)

			-- When a new chat is created, this event is triggered but no spinner is
			-- available yet. After this, the CodeCompanionChatCreated event will be
			-- triggered, which creates the spinner. Here, we need to check if the
			-- spinner exists.
			local spinner = spinners[args.data.id]
			if spinner then
				spinner:enable()
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatHidden",
		callback = function(args)
			log.debug(args.match)
			local chat_id = args.data.id
			local spinner = spinners[chat_id]
			if not spinner then
				log.debug("Spinner", chat_id, "not found")
				return
			end
			spinner:disable()
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatSubmitted",
		callback = function(args)
			log.debug(args.match)
			local chat_id = args.data.id
			local spinner = spinners[chat_id]
			if not spinner then
				log.debug("Spinner", args.data.id, "not found")
				return
			end
			spinner:start()
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionChatDone",
		callback = function(args)
			log.debug(args.match)
			local chat_id = args.data.id
			local spinner = spinners[chat_id]
			if not spinner then
				log.debug("Spinner", chat_id, "not found")
				return
			end
			spinner:stop()
		end,
	})
end

return M
