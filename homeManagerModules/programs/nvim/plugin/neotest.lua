-- ---------------------------------------------------------------------------
-- neotest
--
-- Adapter note: rustaceanvim ships its own neotest adapter that drives
-- cargo-nextest and reuses the running rust-analyzer for test discovery.
-- neotest-rust is the older standalone adapter; registering both makes every
-- test show up twice, so only rustaceanvim's is enabled here.
-- ---------------------------------------------------------------------------
local ok, neotest = pcall(require, "neotest")
if not ok then
  return
end

local adapters = {}

local ok_rust, rust_adapter = pcall(require, "rustaceanvim.neotest")
if ok_rust then
  table.insert(adapters, rust_adapter)
end

neotest.setup({
  adapters = adapters,
  status = { virtual_text = false, signs = true },
  output = { open_on_run = false },
  quickfix = { enabled = false },
})

-- Keymaps live in initLua (mapleader is not set yet when this file runs).
