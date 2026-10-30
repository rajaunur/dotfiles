local M = {
	"williamboman/mason.nvim",
	cmd = "Mason",
	event = "BufReadPre",
}

M.config = function()
	require("mason").setup({
		ui = {
			icons = {
				package_installed = " ",
				package_pending = " ",
				package_uninstalled = " ",
			},
			border = "rounded",
			height = 0.7,
			width = 0.65,
		},
	})
end

return M
