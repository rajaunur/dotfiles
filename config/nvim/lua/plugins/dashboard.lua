local M = {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}

M.opts = function()
	local logo = [[
_____   __                 _____            
___  | / /_____________   ____(_)______ ___ 
__   |/ /_  _ \  __ \_ | / /_  /__  __ `__ \
_  /|  / /  __/ /_/ /_ |/ /_  / _  / / / / /
/_/ |_/  \___/\____/_____/ /_/  /_/ /_/ /_/ 
        ]]

	logo = string.rep("\n", 8) .. logo .. "\n\n"

	local opts = {
		theme = "doom",

		hide = {
			-- this is taken care of by lualine
			-- enabling this messes up the actual laststatus setting after loading a file
			statusline = false,
		},
		config = {
			header = vim.split(logo, "\n"),
        -- stylua: ignore
        center = {
          { action = 'Telescope find_files',                           desc = " Find File",       icon = " ", key = "f" },
          -- { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
          { action = 'Telescope oldfiles',                 desc = " Recent Files",    icon = " ", key = "r" },
          { action = 'Telescope live_grep',                desc = " Find Text",       icon = " ", key = "g" },
          -- { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
        { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
          { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
        },
			footer = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				local text = "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
				text = string.rep("\n", 2) .. text .. "\n"
				text = vim.split(text, "\n")
				return text
			end,
		},
	}
	for _, button in ipairs(opts.config.center) do
		button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
		button.key_format = "  %s"
	end

	-- open dashboard after closing lazy
	if vim.o.filetype == "lazy" then
		vim.api.nvim_create_autocmd("WinClosed", {
			pattern = tostring(vim.api.nvim_get_current_win()),
			once = true,
			callback = function()
				vim.schedule(function()
					vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
				end)
			end,
		})
	end
	return opts
end

return M
