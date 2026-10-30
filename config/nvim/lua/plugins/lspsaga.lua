local M = {
  "nvimdev/lspsaga.nvim",
  -- lazy = false,
  -- event = { "LspAttach" },
}

M.config = function()
  require("lspsaga").setup({
    lightbulb = { enable = false },
    symbol_in_winbar = {
      folder_level = 0,
      separator = "   ",
    },
  })
end

return M
