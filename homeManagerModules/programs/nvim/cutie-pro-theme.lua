-- Cutie Pro colorscheme (https://github.com/mbadolato/iTerm2-Color-Schemes),
-- built on neovim's standard highlight groups instead of a colorscheme plugin.

local bg = '#181818'
local fg = '#d5d0c9'
local red = '#f56e7f'
local green = '#bec975'
local orange = '#f58669'
local teal = '#42d9c5'
local pink = '#d286b7'
local gray = '#88847f' -- bright black
local soft_orange = '#f1bb79'
local sky_blue = '#80c5de'
local mauve = '#b294bb'
local mint = '#9dccbb'
local bwhite = '#ffffff'
local cursor_pink = '#efc4cd'

local dim_bg = '#101010' -- for statuslines / pmenu / tabline
local line_bg = '#232323' -- cursorline / colorcolumn

local hl = vim.api.nvim_set_hl

local groups = {
  -- Base UI
  Normal = { fg = fg, bg = bg },
  NormalFloat = { fg = fg, bg = bg },
  NonText = { fg = gray },
  EndOfBuffer = { fg = bg },
  Cursor = { fg = bg, bg = cursor_pink },

  -- Syntax (also covers @treesitter/LSP semantic tokens via built-in links)
  Comment = { fg = gray, italic = true },
  Constant = { fg = soft_orange },
  String = { fg = green },
  Character = { fg = green },
  Number = { fg = soft_orange },
  Boolean = { fg = soft_orange, bold = true },
  Float = { fg = soft_orange },
  Identifier = { fg = fg },
  Function = { fg = teal, bold = true },
  Statement = { fg = sky_blue, bold = true },
  Conditional = { fg = sky_blue },
  Repeat = { fg = sky_blue },
  Label = { fg = sky_blue },
  Operator = { fg = fg },
  Keyword = { fg = sky_blue, bold = true },
  Exception = { fg = red },
  PreProc = { fg = pink },
  Include = { fg = pink },
  Define = { fg = pink },
  Macro = { fg = pink },
  Type = { fg = mauve },
  StorageClass = { fg = mauve },
  Structure = { fg = mauve },
  Typedef = { fg = mauve },
  Special = { fg = mint },
  SpecialChar = { fg = mint },
  Tag = { fg = sky_blue },
  Delimiter = { fg = fg },
  SpecialComment = { fg = gray, italic = true, bold = true },
  Underlined = { fg = sky_blue, underline = true },
  Ignore = { fg = gray },
  Error = { fg = bwhite, bg = red, bold = true },
  Todo = { fg = bg, bg = soft_orange, bold = true },

  -- Selection / search: reverse-video for legibility.
  Visual = { reverse = true },
  VisualNOS = { reverse = true },
  Search = { fg = bg, bg = orange },
  IncSearch = { fg = bg, bg = soft_orange },
  CurSearch = { fg = bg, bg = soft_orange },

  -- Line / gutter
  CursorLine = { bg = line_bg },
  CursorLineNr = { fg = fg, bold = true },
  LineNr = { fg = gray },
  SignColumn = { bg = bg },
  ColorColumn = { bg = line_bg },
  MatchParen = { fg = bg, bg = soft_orange, bold = true },

  -- Chrome
  StatusLine = { fg = fg, bg = dim_bg },
  StatusLineNC = { fg = gray, bg = dim_bg },
  WinSeparator = { fg = gray, bg = bg },
  VertSplit = { fg = gray, bg = bg },
  TabLine = { fg = gray, bg = dim_bg },
  TabLineFill = { bg = dim_bg },
  TabLineSel = { fg = bg, bg = fg, bold = true },
  Pmenu = { fg = fg, bg = dim_bg },
  PmenuSel = { fg = bg, bg = fg, bold = true },
  PmenuSbar = { bg = dim_bg },
  PmenuThumb = { bg = gray },
  FloatBorder = { fg = gray, bg = bg },

  -- Diff / git
  DiffAdd = { fg = green, bg = '#1e2416' },
  DiffChange = { fg = sky_blue, bg = '#152530' },
  DiffDelete = { fg = red, bg = '#301419' },
  DiffText = { fg = soft_orange, bg = '#332615', bold = true },
  GitSignsAdd = { fg = green },
  GitSignsChange = { fg = sky_blue },
  GitSignsDelete = { fg = red },
}

for group, opts in pairs(groups) do
  hl(0, group, opts)
end

vim.o.background = 'dark'
vim.o.termguicolors = true
