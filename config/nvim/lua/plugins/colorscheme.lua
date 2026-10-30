local M = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Pastikan dimuat paling awal agar warna tema tidak berantakan
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        show_end_of_buffer = false,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          notify = false,
          mini = {
            enabled = true,
          },
        },
      })

      vim.cmd.colorscheme("catppuccin-nvim")
    end,
  },
}

return M
