local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependecies = {
    "williamboman/mason.nvim",
  },
}


M.config = function()
  local on_attach = require("utils.lsp").on_attach

  local signs = { Error = "", Warn = "", Hint = "", Info = "" }

  vim.diagnostic.config({
    virtual_text = false,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = signs.Error,
        [vim.diagnostic.severity.WARN] = signs.Warn,
        [vim.diagnostic.severity.HINT] = signs.Hint,
        [vim.diagnostic.severity.INFO] = signs.Info,
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      },
    },
  })

  vim.lsp.config("*", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        on_attach(client, args.buf)
      end
    end,
  })

  vim.lsp.config("emmet_language_server", {
    filetypes = { "blade", "html", "css", "typescriptreact", "javascriptreact" },
  })

  vim.lsp.enable({
    "tailwindcss",
    "ts_ls",
    "emmet_language_server",
    "html",
    "intelephense", -- PHP
    "eslint_d",
    "gopls",
    "lua_ls",
  })
end

return M
