local M = {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufNewFile", "BufReadPre" },
	main = "ibl",
}

M.opts = function()
	return {
		indent = {
			char = "│",
			tab_char = "│",
		},
		scope = { show_start = false, show_end = false },
		exclude = {
			filetypes = {
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"Trouble",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
			},
		},
	}
end

return M
