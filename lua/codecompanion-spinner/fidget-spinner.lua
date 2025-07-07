local log = require("codecompanion-spinner.log")

local M = {}

function M.setup()
	-- Check if fidget.nvim is installed
	local ok, progress = pcall(require, "fidget.progress")
	if not ok then
		log.warn("fidget.nvim not found, fidget-spinner functionality disabled")
		return
	end

	M.progress = progress
	M.handles = {}

	-- Check if already initialized
	if M.initialized then
		log.debug("fidget-spinner already initialized")
		return
	end

	M:init()
	M.initialized = true
	log.info("fidget-spinner initialized")
end

function M:init()
	local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestStarted",
		group = group,
		callback = function(request)
			log.debug("CodeCompanionRequestStarted - creating progress handle")
			if not request.data or not request.data.id then
				log.warn("Invalid request data in CodeCompanionRequestStarted")
				return
			end
			local handle = M:create_progress_handle(request)
			M:store_progress_handle(request.data.id, handle)
		end,
	})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestFinished",
		group = group,
		callback = function(request)
			log.debug("CodeCompanionRequestFinished - finishing progress handle")
			if not request.data or not request.data.id then
				log.warn("Invalid request data in CodeCompanionRequestFinished")
				return
			end
			local handle = M:pop_progress_handle(request.data.id)
			if handle then
				M:report_exit_status(handle, request)
				handle:finish()
			end
		end,
	})
end

function M:store_progress_handle(id, handle)
	if not id or not handle then
		log.warn("Invalid parameters for store_progress_handle", id, handle)
		return
	end
	M.handles[id] = handle
	log.debug("Stored progress handle for request", id)
end

function M:pop_progress_handle(id)
	if not id then
		log.warn("Invalid id for pop_progress_handle")
		return nil
	end
	local handle = M.handles[id]
	M.handles[id] = nil
	log.debug("Popped progress handle for request", id)
	return handle
end

function M:create_progress_handle(request)
	if not request or not request.data then
		log.error("Invalid request data for create_progress_handle")
		return nil
	end

	local title = " Requesting assistance "
	if request.data.strategy then
		title = title .. "(" .. request.data.strategy .. ")"
	end

	if not M.progress then
		log.error("Fidget progress not initialized")
		return nil
	end

	local handle = M.progress.handle.create({
		title = title,
		message = "In progress...",
		lsp_client = {
			name = M:llm_role_title(request.data.adapter),
		},
	})

	log.debug("Created progress handle with title:", title)
	return handle
end

function M:llm_role_title(adapter)
	if not adapter then
		return "Unknown"
	end

	local parts = {}
	table.insert(parts, adapter.formatted_name or "Unknown")
	if adapter.model and adapter.model ~= "" then
		table.insert(parts, "(" .. adapter.model .. ")")
	end
	return table.concat(parts, " ")
end

function M:report_exit_status(handle, request)
	if not handle or not request or not request.data then
		log.warn("Invalid parameters for report_exit_status")
		return
	end

	if request.data.status == "success" then
		handle.message = "Completed"
	elseif request.data.status == "error" then
		handle.message = " Error"
	else
		handle.message = "󰜺 Cancelled"
	end
	log.debug("Reported exit status:", request.data.status)
end

-- Provide cleanup method
function M.cleanup()
	if M.handles then
		for id, handle in pairs(M.handles) do
			if handle and handle.finish then
				pcall(handle.finish, handle)
			end
		end
		M.handles = {}
	end
	M.initialized = false
	M.progress = nil
end

return M
