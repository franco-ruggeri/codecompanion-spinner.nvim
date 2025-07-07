-- Example configuration for codecompanion-spinner.nvim
-- Place this in your Neovim configuration

return {
	-- CodeCompanion plugin with spinner extension
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"j-hui/fidget.nvim", -- Optional: for progress notifications
		},
		config = function()
			require("codecompanion").setup({
				-- Your codecompanion configuration here
			})
		end,
	},

	-- Spinner extension for CodeCompanion
	{
		"franco-ruggeri/codecompanion-spinner.nvim",
		dependencies = {
			"olimorris/codecompanion.nvim",
			"nvim-lua/plenary.nvim",
			"j-hui/fidget.nvim", -- Optional: for fidget integration
		},
		config = function()
			require("codecompanion-spinner").setup({
				-- Log level for debugging
				log_level = "info", -- "trace", "debug", "info", "warn", "error"

				-- Spinner style: "spinner" (default), "fidget", or "none"
				style = "spinner",
			})
		end,
	},

	-- Fidget.nvim for progress notifications (optional)
	{
		"j-hui/fidget.nvim",
		opts = {
			-- Your fidget configuration here
		},
	},
}
