local M = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
}

M.config = function()
  -- parser custom (blade) harus didaftarkan lewat event TSUpdate
  vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
      require("nvim-treesitter.parsers").blade = {
        install_info = {
          url = "https://github.com/EmranMR/tree-sitter-blade",
          branch = "main",
        },
      }
    end,
  })

  -- ganti ensure_installed (async, skip yang sudah ada)
  require("nvim-treesitter").install({
    "json", "html", "css", "yaml", "bash",
    "go", "typescript", "lua", "javascript", "blade", "tsx",
  })

  -- highlight + indent sekarang diaktifin manual per filetype
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "json", "html", "css", "yaml", "sh", "bash",
      "go", "typescript", "typescriptreact", "lua", "javascript", "blade",
    },
    callback = function()
      vim.treesitter.start()
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
