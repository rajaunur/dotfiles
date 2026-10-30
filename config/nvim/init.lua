require("config.lazy")

local alacritty_padding_group = vim.api.nvim_create_augroup("AlacrittyPadding", { clear = true })


local function alacritty_env()
  if vim.env.TMUX then
    local out = vim.fn.system("tmux show-environment ALACRITTY_WINDOW_ID")
    local id = out:match("ALACRITTY_WINDOW_ID=(%d+)")
    if id then return id end
  end
  return vim.env.ALACRITTY_WINDOW_ID
end

local function set_padding(x, y)
  local id = alacritty_env()
  if not id then return end
  vim.fn.system({
    "alacritty", "msg", "config", "-w", id,
    string.format("window.padding={x=%d,y=%d}", x, y),
  })
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = alacritty_padding_group,
  callback = function() set_padding(0, 0) end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = alacritty_padding_group,
  callback = function() set_padding(10, 10) end,
})
