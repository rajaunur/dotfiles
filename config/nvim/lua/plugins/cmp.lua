local M = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
  },
  event = { "InsertEnter", "CmdlineEnter" },
}

local jsx_markup = {
  jsx_element = true,
  jsx_self_closing_element = true,
  jsx_opening_element = true,
  jsx_fragment = true,
  jsx_text = true,
}

local js_code = {
  jsx_expression = true,
  statement_block = true,
  lexical_declaration = true,
  variable_declarator = true,
  member_expression = true,
  call_expression = true,
  arguments = true,
  object = true,
  arrow_function = true,
  function_declaration = true,
  return_statement = true,
}

local function emmet_allowed()
  local ft = vim.bo.filetype
  if ft ~= "typescriptreact" and ft ~= "javascriptreact" then
    return true
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local ok, node = pcall(vim.treesitter.get_node, {
    pos = { row - 1, math.max(col - 1, 0) },
  })
  if not ok or not node then
    return true
  end

  while node do
    local t = node:type()
    if js_code[t] then
      return false
    end
    if jsx_markup[t] then
      return true
    end
    node = node:parent()
  end

  return false
end

M.config = function()
  local cmp = require("cmp")
  require("luasnip.loaders.from_vscode").lazy_load()

  local kinds = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "M",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  }

  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    formatting = {
      fields = { "abbr", "menu", "kind" },
      format = function(_, vim_item)
        vim_item.kind = " " .. (kinds[vim_item.kind] or "") .. " "
        return vim_item
      end,
      expandable_indicator = false,
    },
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = function()
        for _ = 1, 5 do
          cmp.select_prev_item()
        end
      end,
      ["<C-f>"] = function()
        for _ = 1, 5 do
          cmp.select_next_item()
        end
      end,
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      {
        name = "nvim_lsp",
        entry_filter = function(entry, _)
          local client = entry.source.source and entry.source.source.client
          if client and client.name == "emmet_ls" then
            return emmet_allowed()
          end
          return true
        end,
      },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "path" },
    }),
  })

  -- Cmdline Completion
  -- cmp.setup.cmdline(":", {
  -- 	mapping = cmp.mapping.preset.cmdline(),
  -- 	sources = cmp.config.sources({
  -- 		{ name = "path" },
  -- 	}, {
  -- 		{ name = "cmdline" },
  -- 	}),
  -- 	matching = { disallow_symbol_nonprefix_matching = false },
  -- })
end

return M
