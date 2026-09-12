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

-- The buffer the user last dismissed the split for. Without this, closing the
-- split while errors are still on screen just makes it spring back on the next
-- refresh. Dismissal lasts until you move to another file.
local suppressed_for = nil

-- Set while we are closing the split ourselves, so the WinClosed handler can
-- tell our own close apart from the user pressing q.
local closing = false

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

-- The Rust buffer the split should be reporting on. Prefers the current
-- buffer; falls back to any visible Rust window, so standing inside the
-- split itself (or a sidebar) doesn't count as "left Rust".
local function target_rust_buf()
  local current = vim.api.nvim_get_current_buf()
  if vim.bo[current].filetype == "rust" then
    return current
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_rust_win(win) then
      return vim.api.nvim_win_get_buf(win)
    end
  end
  return nil
end

-- Trouble's own is_open() discriminates by mode, so it is authoritative: it
-- stays correct when the split is closed by hand, and it never claims a
-- window exists after Trouble declined to open an empty one.
local function is_open()
  local t = trouble()
  if not t or not t.is_open then
    return false
  end
  local ok, result = pcall(t.is_open, { mode = MODE })
  return ok and result == true
end

local function open(force)
  if is_open() then
    return
  end
  -- Trouble renders a "No results" pane when a mode matches nothing, so
  -- opening on FileType would put an empty split on screen for every Rust
  -- file and leave it there until rust-analyzer finishes its first check.
  -- Only open once there is something to report -- unless the user asked
  -- for it explicitly.
  if not force then
    local buf = target_rust_buf()
    if not buf or #vim.diagnostic.get(buf) == 0 then
      return
    end
  end
  local t = trouble()
  if not t then
    return
  end
  -- focus=false keeps the cursor in the source buffer.
  pcall(t.open, { mode = MODE, focus = false })
end

local function close()
  if not is_open() then
    return
  end
  closing = true
  pcall(trouble().close, { mode = MODE })
  vim.schedule(function()
    closing = false
  end)
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
    local buf = target_rust_buf()
    if not buf or #vim.diagnostic.get(buf) == 0 then
      -- No Rust buffer in sight, or the file is clean again.
      close()
      return
    end
    if suppressed_for == buf then
      return
    end
    open()
  end)
end

local group = vim.api.nvim_create_augroup("RustDiagnosticsSplit", { clear = true })

vim.api.nvim_create_autocmd({
  "BufWinEnter",
  "BufWinLeave",
  "WinClosed",
  "TabEnter",
  -- rust-analyzer's clippy pass lands well after the buffer opens, so the
  -- split has to react to diagnostics arriving and clearing, not just to
  -- window changes.
  "DiagnosticChanged",
}, {
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

vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(args)
    if closing then
      return
    end
    local win = tonumber(args.match)
    if not win then
      return
    end
    local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
    if ok and vim.bo[buf].filetype == "trouble" then
      suppressed_for = target_rust_buf()
    end
  end,
})

vim.api.nvim_create_user_command("RustDiagAuto", function()
  auto_enabled = not auto_enabled
  if auto_enabled then
    suppressed_for = nil
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
  if is_open() then
    close()
    suppressed_for = target_rust_buf()
  else
    suppressed_for = nil
    open(true)
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
