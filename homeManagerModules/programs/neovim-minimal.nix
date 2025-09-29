{ config, lib, pkgs, ... }:
let
  vp = pkgs.vimPlugins;

  nvimTreesitterWith = vp.nvim-treesitter.withPlugins (p: [
    p.tree-sitter-bash
    p.tree-sitter-json
    p.tree-sitter-lua
    p.tree-sitter-nix
    p.tree-sitter-python
    p.tree-sitter-vim
  ]);

  pluginList = [
    vp.nvim-autopairs
    nvimTreesitterWith
    vp.nvim-cmp
    vp.cmp-nvim-lsp
    vp.vim-commentary
    vp.nvim-lspconfig
    vp.telescope-nvim
    vp.plenary-nvim
  ];

  # Some plugins live under share/vim-plugins/<name>
  pluginRoot = plug:
    let
      pname =
        if plug ? pname then plug.pname
        else if plug ? name then plug.name
        else builtins.baseNameOf (toString plug);
      candidate = "${plug}/share/vim-plugins/${pname}";
    in if builtins.pathExists candidate then candidate else toString plug;

  mkStartLink = plug:
    let
      pname =
        if plug ? pname then plug.pname
        else if plug ? name then plug.name
        else builtins.baseNameOf (toString plug);
    in lib.nameValuePair
      "nvim/site/pack/home-manager/start/${pname}"
      { source = pluginRoot plug; };
in
{
  xdg.enable = true;

  # Put plugins in pack/*/start so Neovim loads them automatically (and headless)
  xdg.dataFile = lib.listToAttrs (map mkStartLink pluginList);

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # CLI deps used by telescope; clipboards for Wayland/X11
    extraPackages =
      (with pkgs; [ ripgrep fd ])
      ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [ wl-clipboard xclip ]);

    # Minimal, self-contained Lua config (no runtime parser installs)
    extraLuaConfig = ''
      -- Ensure pack/*/start is loaded, even headless
      vim.cmd('packloadall')

      -- Leader + basics
      vim.g.mapleader = ' '
      vim.opt.termguicolors = true
      vim.opt.clipboard = 'unnamedplus'

      -- autopairs
      pcall(function() require('nvim-autopairs').setup({}) end)

      -- treesitter: use prebuilt parsers; NEVER auto-install
      pcall(function()
        require('nvim-treesitter.configs').setup({
          highlight = { enable = true },
          indent    = { enable = true },
          auto_install = false,
          -- no ensure_installed here (parsers are already built into the plugin)
        })
      end)

      -- nvim-cmp (+ LSP source)
      pcall(function()
        local cmp = require('cmp')
        cmp.setup({
          mapping = {
            ['<CR>']     = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>']     = cmp.mapping.close(),
          },
          sources = {
            { name = 'nvim_lsp' },
          },
        })
      end)

      -- lspconfig (lightweight bootstrap)
      pcall(function()
        local lspconfig = require('lspconfig')
        local caps = require('cmp_nvim_lsp').default_capabilities()
        for _, s in ipairs({ 'lua_ls', 'bashls' }) do
          if vim.fn.executable(s) == 1 then
            lspconfig[s].setup({ capabilities = caps })
          end
        end
      end)

      -- vim-commentary: no setup required (gc motions)

      -- telescope (+ plenary)
      pcall(function()
        local t = require('telescope')
        t.setup({})
        local b = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', b.find_files, { desc = 'Telescope files'  })
        vim.keymap.set('n', '<leader>fg', b.live_grep,  { desc = 'Telescope grep'   })
        vim.keymap.set('n', '<leader>fb', b.buffers,    { desc = 'Telescope buffers'})
        vim.keymap.set('n', '<leader>fh', b.help_tags,  { desc = 'Telescope help'   })
      end)
    '';
  };
}

