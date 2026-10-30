return {
  "windwp/nvim-ts-autotag",
  event = "InsertEnter", -- Optional: load on insert mode or remove/adjust event as needed
  opts = {
    opts = {
      enable_close = true,          -- Auto close tags
      enable_rename = true,         -- Auto rename pairs
      enable_close_on_slash = false -- Auto close on trailing </
    },
    -- per_filetype = {},
    -- aliases = {},
  },
  config = function(_, opts)
    require("nvim-ts-autotag").setup(opts)
  end,
}
