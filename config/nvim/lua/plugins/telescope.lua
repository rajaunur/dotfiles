local M = {
	"nvim-telescope/telescope.nvim",
  	branch = "master",
	dependecies = {
		"nvim-lua/plenary.nvim",
	},
	lazy = false,
}

M.config = function()
	require("telescope").setup({
		defaults = {
			mappings = {
				i = {
					["<C-k>"] = "move_selection_previous",
					["<C-j>"] = "move_selection_next",
				},
			},
		},
	})
end

M.keys = {
	{ "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps of telescope" },
	{ "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
	{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files in Opened Folder" },
	{ "<leader>fa", "<cmd>Telescope <CR>", desc = "-" },
	{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Find Pattern" },
	{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find Opened Buffers" },
}

return M
