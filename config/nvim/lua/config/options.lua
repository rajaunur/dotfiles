local opt = vim.opt

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance
opt.number = true
opt.termguicolors = true
opt.relativenumber = false
opt.statuscolumn = " %s%=%l "
opt.signcolumn = "no"
opt.cmdheight = 0
opt.scrolloff = 7
opt.completeopt = "menuone,noinsert,noselect"

-- Behaviours
opt.clipboard = "unnamedplus"
opt.hidden = true
opt.errorbells = false
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.backspace = "indent,eol,start"
opt.splitright = true
opt.splitbelow = true
opt.autochdir = false
opt.iskeyword:append("-")
opt.mouse:append("a")
opt.modifiable = true
opt.guicursor = "n-v-c:block,i-ci-ve:ver25-blinkwait200-blinkon200-blinkoff150,r-cr:hor20,o:hor50"
opt.cursorline = true
opt.cursorlineopt = "number"
opt.shada = ""
opt.pumheight = 15
