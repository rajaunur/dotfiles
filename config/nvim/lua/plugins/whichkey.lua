local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}

M.config = function()
  local wk = require("which-key")

  wk.setup({
    preset = "modern",
    triggers = {}, -- matiin popup otomatis
    win = {
      border = "rounded",
    },
  })

  -- popup cuma muncul kalau dipanggil manual
  vim.keymap.set("n", "<leader>?", function()
    wk.show({ keys = "<leader>", mode = "n" })
  end, { desc = "Show leader keymaps" })

  vim.keymap.set("n", "<leader>/", function()
    wk.show({ global = false })
  end, { desc = "Show buffer keymaps" })

  wk.add({
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>l", group = "lsp" },
    { "<leader>b", group = "buffer" },
  })
end

return M
