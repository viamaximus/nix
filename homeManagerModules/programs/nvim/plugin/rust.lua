-- ---------------------------------------------------------------------------
-- rustaceanvim: rust-analyzer + tooling
-- ---------------------------------------------------------------------------

local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = ok_cmp and cmp_nvim_lsp.default_capabilities() or nil

local function read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  return content
end

-- `cargo.allFeatures = true` is a big win on hosted crates -- it surfaces
-- completions for feature-gated APIs you haven't enabled yet. On embedded
-- crates it's actively wrong: HALs gate mutually-exclusive chip families
-- behind features (embassy-rp's rp2040 vs rp235xa, stm32's hundreds of MCU
-- features), so enabling all of them fails to resolve and rust-analyzer
-- reports the whole crate as broken. Detect which kind of project this is.
local embedded_cache = {}

local function is_embedded(root)
  if not root then
    return false
  end
  if embedded_cache[root] ~= nil then
    return embedded_cache[root]
  end

  local result = false

  -- Strongest signal: a cross-compilation target pinned in .cargo/config.toml.
  local cargo_config = read_file(root .. "/.cargo/config.toml") or read_file(root .. "/.cargo/config")
  if cargo_config and cargo_config:match('target%s*=%s*"[^"]*%-none%-') then
    result = true
  end

  -- Next: a no_std crate root.
  if not result then
    for _, rel in ipairs({ "/src/main.rs", "/src/lib.rs" }) do
      local src = read_file(root .. rel)
      if src and src:match("#!%[no_std%]") then
        result = true
        break
      end
    end
  end

  -- Last: recognisable embedded dependencies in the manifest.
  if not result then
    local manifest = read_file(root .. "/Cargo.toml")
    if manifest then
      for _, dep in ipairs({ "embassy%-", "cortex%-m", "riscv%-rt", "esp%-hal", "avr%-device", "rtic" }) do
        if manifest:match(dep) then
          result = true
          break
        end
      end
    end
  end

  embedded_cache[root] = result
  return result
end

vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,

    on_attach = function(_, bufnr)
      if vim.lsp.inlay_hint then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,

    settings = function(project_root, default_settings)
      local settings = default_settings or {}
      local ra = settings["rust-analyzer"] or {}
      local embedded = is_embedded(project_root)

      ra = vim.tbl_deep_extend("force", ra, {
        cargo = {
          allFeatures = not embedded,
          -- Benches and integration tests generally don't build for a
          -- no_std target, so don't ask rust-analyzer to try.
          allTargets = not embedded,
          buildScripts = { enable = true },
        },
        check = {
          command = "clippy",
          allTargets = not embedded,
          extraArgs = { "--no-deps" },
        },
        procMacro = { enable = true },
        files = {
          excludeDirs = { ".direnv", ".git", "target", "result" },
        },
        diagnostics = { experimental = { enable = true } },
        inlayHints = {
          bindingModeHints = { enable = false },
          closureReturnTypeHints = { enable = "with_block" },
          lifetimeElisionHints = { enable = "skip_trivial" },
        },
      })

      if embedded then
        -- Feature selection for a no_std crate has to come from the project
        -- itself; guessing produces resolution errors.
        ra.cargo.features = ra.cargo.features or {}
      end

      settings["rust-analyzer"] = ra
      return settings
    end,
  },

  tools = {
    float_win_config = { border = "rounded" },
    enable_clippy = true,
  },
}

-- Global Rust keymaps live in initLua (mapleader is not set yet here).

-- `K` in a Rust buffer gets rustaceanvim's richer hover (actions submenu).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("RustaceanKeymaps", { clear = true }),
  pattern = "rust",
  callback = function(args)
    vim.keymap.set("n", "K", "<cmd>RustLsp hover actions<CR>", {
      buffer = args.buf,
      silent = true,
      desc = "Rust hover actions",
    })
  end,
})
