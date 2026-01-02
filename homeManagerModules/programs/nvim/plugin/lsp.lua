-- Get default capabilities from nvim-cmp
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = ok_cmp and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

-- LSP keybinds (applied when LSP attaches to buffer)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }

    -- Navigation
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Go to definition
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)          -- Go to declaration
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)           -- Find references
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)       -- Go to implementation
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)      -- Go to type definition

    -- Documentation
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                 -- Hover documentation
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)    -- Signature help

    -- Code actions
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)       -- Rename symbol
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)  -- Code actions
    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)        -- Format buffer

    -- Diagnostics
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)         -- Previous diagnostic
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)         -- Next diagnostic
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- Show diagnostic
  end,
})

-- Nix LSP (nil) using new vim.lsp.config API
vim.lsp.config.nil_ls = {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
  capabilities = capabilities,
  settings = {
    ['nil'] = {
      formatting = {
        command = { "alejandra" },
      },
      diagnostics = {
        ignored = {},
        excludedFiles = {},
      },
    },
  },
}

vim.lsp.enable('nil_ls')
