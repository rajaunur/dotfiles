local M = {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
}

M.config = function()
	require("lualine").setup({
		options = {
			globalstatus = true,
			section_separators = { left = "", right = "" },
			component_separators = { left = "|", right = "|" },
		},
	})
end

return M
