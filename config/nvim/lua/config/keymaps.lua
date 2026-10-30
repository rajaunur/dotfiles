local keymap = vim.keymap

local opts = { noremap = true, silent = true }

-- Pane Navigation
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Edit
keymap.set("n", "<leader>w", "<cmd>w<CR>", opts)
keymap.set("n", "<leader>q", "<cmd>q<CR>", opts)
keymap.set("n", "<leader>Q", "<cmd>qa<CR>", opts)

-- Windows
keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", opts)
keymap.set("n", "<leader>sh", "<cmd>split<CR>", opts)

-- Comment & Indent
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Buffer
keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", opts)
keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", opts)
keymap.set("n", "]b", "<cmd>BufferLineCyclePrev<CR>", opts)
keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<CR>", opts)
keymap.set("n", "[B", "<cmd>BufferLineMovePrev<CR>", opts)
keymap.set("n", "]B", "<cmd>BufferLineMoveNext<CR>", opts)
keymap.set("n", "<S-x>", "<cmd>Bdelete<CR>", opts)

keymap.set('i', 'jk', '<Esc>', opts)

vim.api.nvim_set_keymap("n", "<C-_>", "gcc", { noremap = false })
vim.api.nvim_set_keymap("v", "<C-_>", "gcc", { noremap = false })
