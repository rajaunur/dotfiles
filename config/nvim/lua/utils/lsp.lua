local M = {
	on_attach = function(client, bufnr)
		local opts = { noremap = true, silent = true, buffer = bufnr }
		local keymap = vim.keymap
		keymap.set("n", "<leader>gf", "<cmd>Lspsaga finder<CR>", opts)
		keymap.set("n", "<leader>gD", "<cmd>Lspsaga goto_definition<CR>", opts)
		keymap.set("n", "<leader>gd", "<cmd>Lspsaga peek_definition<CR>", opts)
		keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
		keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
		keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
		keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
		keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
		keymap.set("n", "<leader>nd", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
		keymap.set("n", "<leader>pd", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
	end,
}

return M
