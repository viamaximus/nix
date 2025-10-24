{ lib, config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rustc cargo clippy rustfmt rust-analyzer
    pkg-config
    taplo
  ];

  programs.neovim =
  let
    toLua     = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      xclip
      wl-clipboard
      luajitPackages.lua-lsp
      # rnix-lsp
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-autopairs

      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./nvim/plugin/lsp.lua;
      }

      {
        plugin = comment-nvim;
        config = toLua ''require("Comment").setup()'';
      }

      neodev-nvim

      # Completion stack
      nvim-cmp
      {
        plugin = nvim-cmp;
        config = toLuaFile ./nvim/plugin/cmp.lua;
      }
      cmp-nvim-lsp
      cmp_luasnip
      luasnip
      friendly-snippets
      lspkind-nvim

      # UI bits
      lualine-nvim
      nvim-web-devicons

      ################
      # Treesitter
      ################
      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.rust
          p.toml
          p.lua
          p.vim
          p.bash
          p.python
          p.json
          p.nix
          p.query
        ]));
        config = toLuaFile ./nvim/plugin/treesitter.lua;
      }

      ################
      # Telescope
      ################
      {
        plugin = telescope-nvim;
        config = toLuaFile ./nvim/plugin/telescope.lua;
      }
      telescope-fzf-native-nvim

      ################
      # Rust goodies
      ################
      rustaceanvim      # maintained successor to rust-tools
      conform-nvim      # lightweight formatter manager
      crates-nvim       # Cargo.toml helpers
    ];

    extraLuaConfig = ''
      -- autopairs
      require("nvim-autopairs").setup({})

      -- your existing options
      ${builtins.readFile ./nvim/options.lua}

      -------------------------------------------------------------------
      -- rustaceanvim: Rust LSP (rust-analyzer) + tools
      -------------------------------------------------------------------
      local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = ok_cmp and cmp_nvim_lsp.default_capabilities() or nil

      vim.g.rustaceanvim = {
        server = {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              check = { command = "clippy" },
            },
          },
        },
        tools = { float_win_config = { border = "rounded" } },
      }

      -------------------------------------------------------------------
      -- conform.nvim: format on save (rustfmt / taplo)
      -------------------------------------------------------------------
      require("conform").setup({
        formatters_by_ft = {
          rust = { "rustfmt" },
          toml = { "taplo" },
        },
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 1000,
        },
      })

      -------------------------------------------------------------------
      -- crates.nvim: handy helpers in Cargo.toml
      -------------------------------------------------------------------
      pcall(function()
        require("crates").setup({})
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "toml",
          callback = function()
            local map = function(lhs, rhs)
              vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true })
            end
            map("<leader>cv", require("crates").show_versions_popup)
            map("<leader>cu", require("crates").upgrade_all_crates)
          end,
        })
      end)
    '';
  };
}

