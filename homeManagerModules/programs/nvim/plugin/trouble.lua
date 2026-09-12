require("trouble").setup({
  auto_close = false,
  auto_open = false,
  focus = true,
  icons = {
    indent = {
      fold_open = "",
      fold_closed = "",
    },
    folder_closed = "",
    folder_open = "",
  },
  modes = {
    -- Bottom split showing only the CURRENT file's diagnostics, rustlings-style
    -- Driven by rust-analyzer's clippy-on-save; see rust-diagnostics.lua
    buf_diagnostics = {
      mode = "diagnostics",
      filter = { buf = 0 },
      focus = false,
      auto_close = false,
      win = { position = "bottom", size = 12 },
      title = "Diagnostics (current file)",
    },
  },
})
