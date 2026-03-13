{
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    pkg-config
    taplo
  ];

  programs.neovim = let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
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
      nil
      clang-tools
      cmake-language-server
      alejandra
      statix
      lazygit

      # Copilot / CopilotChat deps
      nodejs_20
      curl
      ripgrep
      git
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
      {
        plugin = nvim-cmp;
        config = toLuaFile ./nvim/plugin/cmp.lua;
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      luasnip
      friendly-snippets
      lspkind-nvim

      ################
      # GitHub Copilot
      ################
      copilot-vim
      CopilotChat-nvim

      # UI bits
      lualine-nvim
      nvim-web-devicons

      ################
      # Treesitter
      ################
      {
        plugin = nvim-treesitter.withPlugins (p: [
          p.c
          p.cpp
          p.cmake
          p.make
          p.rust
          p.toml
          p.lua
          p.vim
          p.bash
          p.python
          p.json
          p.nix
          p.query
        ]);
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
      telescope-ui-select-nvim

      ################
      # Debugging
      ################
      mason-nvim
      mason-nvim-dap-nvim
      {
        plugin = nvim-dap;
        config = toLuaFile ./nvim/plugin/dap.lua;
      }
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-nio

      ################
      # Rust goodies
      ################
      rustaceanvim # maintained successor to rust-tools
      conform-nvim # lightweight formatter manager
      crates-nvim # Cargo.toml helpers

      ################
      # File Explorer
      ################
      {
        plugin = neo-tree-nvim;
        config = toLuaFile ./nvim/plugin/neo-tree.lua;
      }
      nui-nvim # required for neo-tree
      plenary-nvim # required for neo-tree (also required for CopilotChat)

      ################
      # Git Integration
      ################
      {
        plugin = gitsigns-nvim;
        config = toLua ''require("gitsigns").setup()'';
      }

      ################
      # UI Enhancements
      ################
      {
        plugin = bufferline-nvim;
        config = toLua ''require("bufferline").setup({})'';
      }
      {
        plugin = which-key-nvim;
        config = toLua ''require("which-key").setup({})'';
      }
      {
        plugin = trouble-nvim;
        config = toLuaFile ./nvim/plugin/trouble.lua;
      }
      {
        plugin = nvim-colorizer-lua;
        config = toLua ''require("colorizer").setup()'';
      }
      {
        plugin = alpha-nvim;
        config = toLua ''require("alpha").setup(require("alpha.themes.startify").config)'';
      }

      ################
      # Editing Enhancements
      ################
      {
        plugin = nvim-surround;
        config = toLua ''require("nvim-surround").setup({})'';
      }
      {
        plugin = todo-comments-nvim;
        config = toLua ''require("todo-comments").setup({})'';
      }

      ################
      # Navigation
      ################
      {
        plugin = aerial-nvim;
        config = toLuaFile ./nvim/plugin/aerial.lua;
      }

      ################
      # Git Enhancements
      ################
      {
        plugin = lazygit-nvim;
        config = toLua ''vim.g.lazygit_floating_window_scaling_factor = 0.9'';
      }
      {
        plugin = diffview-nvim;
        config = toLua ''require("diffview").setup({})'';
      }

      ################
      # Utilities
      ################
      undotree
    ];

    initLua = ''
      -- autopairs
      require("nvim-autopairs").setup({})

      -- your existing options
      ${builtins.readFile ./nvim/options.lua}

      -- -------------------------------------------------------------------
      -- Keybinds for plugins
      -- -------------------------------------------------------------------
      -- Neo-tree (file explorer)
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true, desc = 'Toggle file explorer' })
      vim.keymap.set('n', '<leader>o', ':Neotree focus<CR>', { silent = true, desc = 'Focus file explorer' })

      -- Bufferline (buffer tabs)
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { silent = true, desc = 'Next buffer' })
      vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { silent = true, desc = 'Previous buffer' })
      vim.keymap.set('n', '<leader>c', ':bdelete<CR>', { silent = true, desc = 'Close buffer' })
      vim.keymap.set('n', '<leader>bp', ':BufferLinePick<CR>', { silent = true, desc = 'Pick buffer' })

      -- Trouble (diagnostics list)
      vim.keymap.set('n', '<leader>xx', ':Trouble diagnostics toggle<CR>', { silent = true, desc = 'Toggle diagnostics' })
      vim.keymap.set('n', '<leader>xq', ':Trouble quickfix toggle<CR>', { silent = true, desc = 'Toggle quickfix' })

      -- Gitsigns
      vim.keymap.set('n', '<leader>gb', ':Gitsigns blame_line<CR>', { silent = true, desc = 'Git blame line' })
      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { silent = true, desc = 'Preview hunk' })
      vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', { silent = true, desc = 'Reset hunk' })
      vim.keymap.set('n', ']h', ':Gitsigns next_hunk<CR>', { silent = true, desc = 'Next git hunk' })
      vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<CR>', { silent = true, desc = 'Previous git hunk' })

      -- Lazygit
      vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { silent = true, desc = 'Open LazyGit' })

      -- Diffview
      vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { silent = true, desc = 'Open diff view' })
      vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', { silent = true, desc = 'Close diff view' })
      vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory %<CR>', { silent = true, desc = 'File history' })

      -- Aerial (code outline)
      vim.keymap.set('n', '<leader>a', ':AerialToggle<CR>', { silent = true, desc = 'Toggle code outline' })

      -- Undotree
      vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { silent = true, desc = 'Toggle undo tree' })

      -- DAP
      vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { silent = true, desc = 'Debug continue' })
      vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { silent = true, desc = 'Debug step over' })
      vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { silent = true, desc = 'Debug step into' })
      vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { silent = true, desc = 'Debug step out' })
      vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { silent = true, desc = 'Toggle breakpoint' })
      vim.keymap.set('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { silent = true, desc = 'Conditional breakpoint' })
      vim.keymap.set('n', '<leader>dr', function() require('dap').repl.open() end, { silent = true, desc = 'Open debug REPL' })
      vim.keymap.set('n', '<leader>dl', function() require('dap').run_last() end, { silent = true, desc = 'Run last debug config' })
      vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { silent = true, desc = 'Toggle debug UI' })

      -- Todo comments
      vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end, { silent = true, desc = 'Next todo' })
      vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end, { silent = true, desc = 'Previous todo' })
      vim.keymap.set('n', '<leader>xt', ':TodoTrouble<CR>', { silent = true, desc = 'Todo list (Trouble)' })
      vim.keymap.set('n', '<leader>st', ':TodoTelescope<CR>', { silent = true, desc = 'Search todos (Telescope)' })

      -- -------------------------------------------------------------------
      -- GitHub Copilot (copilot.vim)
      -- -------------------------------------------------------------------
      -- Let nvim-cmp own <Tab> and delegate to Copilot/snippets when appropriate
      vim.g.copilot_no_tab_map = true

      -- Secondary Copilot inline-suggestion controls
      vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        silent = true,
        replace_keycodes = false,
        desc = 'Copilot accept',
      })
      vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', { silent = true, desc = 'Copilot next suggestion' })
      vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)', { silent = true, desc = 'Copilot previous suggestion' })

      -- -------------------------------------------------------------------
      -- CopilotChat.nvim
      -- -------------------------------------------------------------------
      pcall(function()
        require("CopilotChat").setup({
          window = { layout = "vertical", width = 0.5 },
          auto_insert_mode = true,
        })
      end)

      vim.keymap.set('n', '<leader>cc', ':CopilotChat<CR>', { silent = true, desc = 'CopilotChat' })
      vim.keymap.set('n', '<leader>ct', ':CopilotChatToggle<CR>', { silent = true, desc = 'Toggle CopilotChat' })
      vim.keymap.set('n', '<leader>cr', ':CopilotChatReset<CR>', { silent = true, desc = 'Reset CopilotChat' })

      -- Visual-mode helpers (select code first)
      vim.keymap.set('v', '<leader>ce', ':CopilotChatExplain<CR>', { silent = true, desc = 'Explain selection' })
      vim.keymap.set('v', '<leader>cf', ':CopilotChatFix<CR>', { silent = true, desc = 'Fix selection' })
      vim.keymap.set('v', '<leader>co', ':CopilotChatOptimize<CR>', { silent = true, desc = 'Optimize selection' })
      vim.keymap.set('v', '<leader>cd', ':CopilotChatDocs<CR>', { silent = true, desc = 'Docs for selection' })
      vim.keymap.set('v', '<leader>cT', ':CopilotChatTests<CR>', { silent = true, desc = 'Tests for selection' })

      -- Optional: if telescope-ui-select.nvim is installed, use it for vim.ui.select
      pcall(function()
        require("telescope").load_extension("ui-select")
      end)

      -- -------------------------------------------------------------------
      -- rustaceanvim: Rust LSP (rust-analyzer) + tools
      -- -------------------------------------------------------------------
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

      -- -------------------------------------------------------------------
      -- conform.nvim: format on save (rustfmt / taplo)
      -- -------------------------------------------------------------------
      require("conform").setup({
        formatters_by_ft = {
          c = { "clang_format" },
          cpp = { "clang_format" },
          rust = { "rustfmt" },
          toml = { "taplo" },
          nix = { "alejandra" },
        },
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 1000,
        },
      })

      -- -------------------------------------------------------------------
      -- crates.nvim: handy helpers in Cargo.toml
      -- -------------------------------------------------------------------
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
