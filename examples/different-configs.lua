-- Different configuration examples for codecompanion-spinner.nvim

-- Example 1: Default spinner style (recommended)
local config_spinner = {
	"franco-ruggeri/codecompanion-spinner.nvim",
	dependencies = {
		"olimorris/codecompanion.nvim",
		"nvim-lua/plenary.nvim",
	},
	opts = {
		log_level = "info",
		style = "spinner", -- Use custom spinner in chat buffers
	},
}

-- Example 2: Fidget integration style
local config_fidget = {
	"franco-ruggeri/codecompanion-spinner.nvim",
	dependencies = {
		"olimorris/codecompanion.nvim",
		"nvim-lua/plenary.nvim",
		"j-hui/fidget.nvim", -- Required for fidget style
	},
	opts = {
		log_level = "info",
		style = "fidget", -- Use fidget.nvim for progress notifications
	},
}

-- Example 3: Disabled spinner
local config_none = {
	"franco-ruggeri/codecompanion-spinner.nvim",
	dependencies = {
		"olimorris/codecompanion.nvim",
		"nvim-lua/plenary.nvim",
	},
	opts = {
		log_level = "info",
		style = "none", -- Disable all spinner functionality
	},
}

-- Example 4: Runtime configuration switching
local config_dynamic = {
	"franco-ruggeri/codecompanion-spinner.nvim",
	dependencies = {
		"olimorris/codecompanion.nvim",
		"nvim-lua/plenary.nvim",
		"j-hui/fidget.nvim", -- Optional
	},
	config = function()
		-- Check if fidget is available and configure accordingly
		local has_fidget = pcall(require, "fidget")

		require("codecompanion-spinner").setup({
			log_level = "info",
			style = has_fidget and "fidget" or "spinner",
		})

		-- Add user commands to switch styles
		vim.api.nvim_create_user_command("SpinnerStyleSpinner", function()
			require("codecompanion-spinner").setup({ style = "spinner" })
			vim.notify("Switched to spinner style")
		end, {})

		vim.api.nvim_create_user_command("SpinnerStyleFidget", function()
			require("codecompanion-spinner").setup({ style = "fidget" })
			vim.notify("Switched to fidget style")
		end, {})

		vim.api.nvim_create_user_command("SpinnerStyleNone", function()
			require("codecompanion-spinner").setup({ style = "none" })
			vim.notify("Disabled spinner")
		end, {})
	end,
}

-- Return the configuration you want to use
return config_spinner -- or config_fidget, config_none, config_dynamic
