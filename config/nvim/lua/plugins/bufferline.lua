local M = {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	lazy = false,
}

M.config = function()
	local bufferline = require("bufferline")
	bufferline.setup({
		options = {
			-- diagnostics = "nvim_lsp",
			-- diagnostics_indicator = function(count, level)
			-- 	local icon = level:match("error") and "" or ""
			-- 	return "" .. icon .. " " .. count
			-- end,
			style_preset = { bufferline.style_preset.no_bold },
			offsets = {
				{
					filetype = "neo-tree",
					text = "󰔱 neotree",
					highlight = "Directory",
					text_align = "left",
					separator = true,
				},
			},
			close_command = "Bdelete! %d",
			highlights = {
				buffer_selected = {
					bold = false,
					italic = true,
				},
			},
		},
	})
end

return M
