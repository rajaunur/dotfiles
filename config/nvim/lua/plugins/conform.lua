local M = {
	"stevearc/conform.nvim",
	opts = {},
	event = { "BufWritePre", "BufNewFile" },
}

M.config = function()
	require("conform").setup({
		formatters_by_ft = {
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			blade = { "blade-formatter" },
			go = { "gofumpt" },
			lua = { "stylua" },
		},
		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},
	})
end

return M
