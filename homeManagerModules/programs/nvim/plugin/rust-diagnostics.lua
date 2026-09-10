-- ---------------------------------------------------------------------------
-- Rust: auto-opening diagnostics split (rustlings-style)
--
-- rust-analyzer is already configured to run `cargo clippy` on save (see
-- neovim.nix). This file only handles *presentation*: whenever a Rust buffer
-- is on screen, a bottom split lists that buffer's errors and warnings, and
-- it goes away when the last Rust buffer does.
-- ---------------------------------------------------------------------------

local MODE = "buf_diagnostics"

-- Master switch, flipped by :RustDiagAuto.
local auto_enabled = true

-- Our own view of whether the split is up. Trouble's is_open() is keyed on the
-- active view rather than the mode, so tracking it here avoids close() calls
-- that would tear down an unrelated Trouble window.
local is_open = false

local function trouble()
  local ok, mod = pcall(require, "trouble")
  if not ok then
    return nil
  end
  return mod
end

-- Rust buffers only. Skip Trouble's own window, terminals, neo-tree, etc.
local function is_rust_win(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  -- Floating windows (hover, rustaceanvim popups) shouldn't count.
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].filetype == "rust"
end

local function any_rust_visible()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_rust_win(win) then
      return true
    end
  end
  return false
end

local function open()
  if is_open then
    return
  end
  local t = trouble()
  if not t then
    return
  end
  -- focus=false keeps the cursor in the source buffer.
  local ok = pcall(t.open, { mode = MODE, focus = false })
  is_open = ok
end

local function close()
  if not is_open then
    return
  end
  local t = trouble()
  if t then
    pcall(t.close, { mode = MODE })
  end
  is_open = false
end

-- Debounced so a single :bdelete or window split doesn't thrash the layout.
local pending = false
local function refresh()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    if not auto_enabled then
      return
    end
    if any_rust_visible() then
      open()
    else
      close()
    end
  end)
end

local group = vim.api.nvim_create_augroup("RustDiagnosticsSplit", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave", "WinClosed", "TabEnter" }, {
  group = group,
  callback = refresh,
})

-- FileType fires before the buffer is attached to a window on first open, so
-- it needs its own (scheduled) pass.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "rust",
  callback = refresh,
})

-- If the split was closed by hand (:q inside it), stop believing it's open so
-- the next Rust buffer re-opens it.
vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(args)
    local win = tonumber(args.match)
    if not win then
      return
    end
    local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
    if ok and vim.bo[buf].filetype == "trouble" then
      is_open = false
    end
  end,
})

vim.api.nvim_create_user_command("RustDiagAuto", function()
  auto_enabled = not auto_enabled
  if auto_enabled then
    vim.notify("Rust diagnostics split: auto", vim.log.levels.INFO)
    refresh()
  else
    vim.notify("Rust diagnostics split: manual", vim.log.levels.INFO)
    close()
  end
end, { desc = "Toggle the auto-opening Rust diagnostics split" })

-- Keymaps live in initLua, which runs after `vim.g.mapleader` is set; this
-- file is sourced from init.vim, before it. Expose a command instead.
vim.api.nvim_create_user_command("RustDiagToggle", function()
  if is_open then
    close()
  else
    open()
  end
end, { desc = "Toggle the current-file diagnostics split" })

-- ---------------------------------------------------------------------------
-- Inline diagnostics
--
-- tiny-inline-diagnostic renders the full message next to the offending line
-- instead of Neovim's truncated virtual_text stub, so the two must not both be
-- on or every diagnostic shows up twice.
-- ---------------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})

pcall(function()
  require("tiny-inline-diagnostic").setup({
    preset = "modern",
    options = {
      show_source = { enabled = true, if_many = true },
      multilines = { enabled = true, always_show = false },
      show_all_diags_on_cursorline = false,
      throttle = 0,
    },
  })
end)
