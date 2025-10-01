{ config, lib, pkgs, ... }:
let
  vp = pkgs.vimPlugins;

  # Prebuild Tree-sitter parsers (no runtime downloads/writes)
  nvimTreesitterWith = vp.nvim-treesitter.withPlugins (p: [
    p.tree-sitter-bash
    p.tree-sitter-json
    p.tree-sitter-lua
    p.tree-sitter-nix
    p.tree-sitter-python
    p.tree-sitter-vim
  ]);

  # Your plugin set (+ plenary for telescope)
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

  # Some plugins install under share/vim-plugins/<name>
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

  py = pkgs.python3Packages;
in
{
  xdg.enable = true;

  # Put plugins in pack/*/start so Neovim always sees them
  xdg.dataFile = lib.listToAttrs (map mkStartLink pluginList);

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Tools on $PATH inside the nvim wrapper
    extraPackages =
      (with pkgs; [
        ripgrep
        fd
        python3
        ruff        # use Ruff's built-in LSP: `ruff server`
        pyright     # fallback LSP (node-based)
      ])
      ++ lib.optional (builtins.hasAttr "basedpyright" py) py.basedpyright
      ++ lib.optional (builtins.hasAttr "python-lsp-server" py) py."python-lsp-server"
      ++ [ py.black ];

    extraLuaConfig = ''
      -- Ensure pack/*/start is loaded (helps in headless)
      vim.cmd('packloadall')

      -- UI niceties
      vim.g.mapleader = ' '
      vim.opt.termguicolors   = true
      vim.opt.clipboard       = 'unnamedplus'
      vim.opt.number          = true
      vim.opt.relativenumber  = true

      -- autopairs
      pcall(function() require('nvim-autopairs').setup({}) end)

      -- treesitter (prebuilt parsers)
      pcall(function()
        require('nvim-treesitter.configs').setup({
          highlight    = { enable = true },
          indent       = { enable = true },
          auto_install = false,
        })
      end)

      -- nvim-cmp (+ LSP source)
      pcall(function()
        local ok_cmp, cmp = pcall(require, 'cmp')
        if not ok_cmp then return end
        cmp.setup({
          mapping = {
            ['<CR>']       = cmp.mapping.confirm({ select = true }),
            ['<C-Space>']  = cmp.mapping.complete(),
            ['<C-e>']      = cmp.mapping.close(),
          },
          sources = { { name = 'nvim_lsp' } },
        })
      end)

      -- LSP
      pcall(function()
        local ok, lspconfig = pcall(require, 'lspconfig')
        if not ok then return end

        local caps = {}
        local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
        if ok_cmp then caps = cmp_lsp.default_capabilities() end

        local function setup_if_exec(server, bin, opts)
          local exe = bin or server
          if vim.fn.executable(exe) == 1 then
            lspconfig[server].setup(opts or {})
          end
        end

        -- Python: prefer basedpyright -> pyright -> pylsp
        setup_if_exec('basedpyright', 'basedpyright', { capabilities = caps })
        setup_if_exec('pyright',      'pyright',      { capabilities = caps })
        setup_if_exec('pylsp',        'pylsp',        { capabilities = caps })

        -- Ruff’s built-in LSP (replaces deprecated ruff-lsp)
        setup_if_exec('ruff', 'ruff', {
          capabilities = caps,
          cmd = { 'ruff', 'server' },
        })

        -- Format-on-save for Python
        local function format_python_buf()
          local file = vim.api.nvim_buf_get_name(0)
          -- try LSP formatting first
          local clients = vim.lsp.get_active_clients({ bufnr = 0 })
          for _, c in ipairs(clients) do
            if c.supports_method and c:supports_method('textDocument/formatting') then
              vim.lsp.buf.format({ async = false })
              return
            end
          end
          -- then Ruff formatter, then Black
          if vim.fn.executable('ruff') == 1 then
            vim.cmd('silent! write')
            vim.fn.jobstart({ 'ruff', 'format', file }, { stdout_buffered = true })
            return
          end
          if vim.fn.executable('black') == 1 then
            vim.cmd('silent! write')
            vim.fn.jobstart({ 'black', file }, { stdout_buffered = true })
          end
        end

        vim.api.nvim_create_autocmd('BufWritePre', {
          pattern = { '*.py' },
          callback = format_python_buf,
        })
      end)

      -- vim-commentary: no setup (use `gc` motions)

      -- telescope (+ plenary)
      pcall(function()
        local ok_t, t = pcall(require, 'telescope')
        if not ok_t then return end
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

