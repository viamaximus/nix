require("aerial").setup({
  -- Automatically open aerial when entering supported buffers
  on_attach = function(bufnr)
    -- Toggle aerial with <leader>a
    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { buffer = bufnr })
  end,

  -- Show symbols in right split
  layout = {
    default_direction = "right",
    placement = "edge",
  },

  -- Filter symbols to show
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Module",
    "Method",
    "Struct",
  },

  -- Show line numbers in aerial window
  show_guides = true,
})
