{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  fenix = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};

  # One matched toolchain, from fenix rather than nixpkgs.
  # `rustup` also can't live alongside this: it ships shims at
  # bin/{cargo,rustc,rustfmt,clippy-driver} and home.packages' buildEnv fails
  # hard on a conflicting subpath.
  rustToolchain = fenix.combine (
    [
      fenix.stable.cargo
      fenix.stable.rustc
      fenix.stable.clippy
      fenix.stable.rustfmt
      fenix.stable.rust-src # rust-analyzer resolves std through this
      fenix.stable.rust-analyzer
      fenix.stable.llvm-tools # cargo-binutils, defmt
    ]
    ++ map (target: fenix.targets.${target}.stable.rust-std) config.features.rust.embeddedTargets
  );
in {
  options.features.rust.embeddedTargets = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "thumbv6m-none-eabi" # Cortex-M0/M0+ -- RP2040
      "thumbv7em-none-eabihf" # Cortex-M4F/M7F -- STM32F4, nRF52
    ];
    example = [];
    description = ''
      Bare-metal Rust targets to install a std for, via fenix. Each one adds a
      rust-std to the closure, so set this to [] on hosts that never do
      embedded work.
    '';
  };

  config = {
    home.packages =
      [rustToolchain]
      ++ (with pkgs; [
        # Rust tooling (standalone binaries -- no ABI coupling to the toolchain)
        cargo-generate
        cargo-seek
        cargo-nextest
        cargo-expand
        cargo-edit
        cargo-audit
        cargo-criterion # runs criterion benches with a proper reporter
        cargo-machete # finds unused dependencies
        cargo-deny # license / advisory policy checks
        bacon
        watchexec
        pkg-config
        taplo
        probe-rs-tools # flash + debug embedded targets (embassy template runner)

        # C / C++
        # gcc13 is already provided globally by programs/common.nix
        # clangd (clang-tools, below) works fine alongside gcc13.
        gdb
        lldb.out # provides lldb-dap for nvim-dap
        valgrind
        cppcheck
        bear # generates compile_commands.json for clangd

        # Reference
        man-pages
        man-pages-posix
      ]);

    # `cargo install` (e.g. rustlings) puts binaries here
    home.sessionPath = ["$HOME/.cargo/bin"];

    programs.neovim = let
      toLua = str: "lua << EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in {
      enable = true;

      # Keep legacy defaults (providers on) regardless of stateVersion < 26.05.
      withRuby = true;
      withPython3 = true;

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

        curl
        ripgrep
        git
      ];

      plugins = with pkgs.vimPlugins; [
        nvim-autopairs

        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./nvim/plugin/lsp.lua;
          type = "viml";
        }

        {
          plugin = comment-nvim;
          config = toLua ''require("Comment").setup()'';
          type = "viml";
        }

        neodev-nvim

        # Completion stack
        {
          plugin = nvim-cmp;
          config = toLuaFile ./nvim/plugin/cmp.lua;
          type = "viml";
        }
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp_luasnip
        luasnip
        friendly-snippets
        lspkind-nvim

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
          type = "viml";
        }

        ################
        # Telescope
        ################
        {
          plugin = telescope-nvim;
          config = toLuaFile ./nvim/plugin/telescope.lua;
          type = "viml";
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
          type = "viml";
        }
        nvim-dap-ui
        nvim-dap-virtual-text
        nvim-nio

        ################
        # Rust goodies
        ################
        {
          plugin = rustaceanvim; # maintained successor to rust-tools
          config = toLuaFile ./nvim/plugin/rust.lua;
          type = "viml";
        }
        conform-nvim # lightweight formatter manager
        crates-nvim # Cargo.toml helpers

        ################
        # Testing
        ################
        {
          plugin = neotest;
          config = toLuaFile ./nvim/plugin/neotest.lua;
          type = "viml";
        }

        ################
        # Task runner
        ################
        {
          plugin = overseer-nvim;
          config = toLuaFile ./nvim/plugin/overseer.lua;
          type = "viml";
        }

        ################
        # File Explorer
        ################
        {
          plugin = neo-tree-nvim;
          config = toLuaFile ./nvim/plugin/neo-tree.lua;
          type = "viml";
        }
        nui-nvim # required for neo-tree
        plenary-nvim # required for neo-tree

        ################
        # Git Integration
        ################
        {
          plugin = gitsigns-nvim;
          config = toLua ''require("gitsigns").setup()'';
          type = "viml";
        }

        ################
        # UI Enhancements
        ################
        {
          plugin = bufferline-nvim;
          config = toLua ''require("bufferline").setup({})'';
          type = "viml";
        }
        {
          plugin = which-key-nvim;
          config = toLua ''require("which-key").setup({})'';
          type = "viml";
        }
        {
          plugin = trouble-nvim;
          config = toLuaFile ./nvim/plugin/trouble.lua;
          type = "viml";
        }
        {
          # Auto-opening current-file diagnostics split + inline diagnostics.
          plugin = tiny-inline-diagnostic-nvim;
          config = toLuaFile ./nvim/plugin/rust-diagnostics.lua;
          type = "viml";
        }
        {
          # Progress spinner while rust-analyzer / cargo check runs.
          plugin = fidget-nvim;
          config = toLua ''require("fidget").setup({ notification = { window = { winblend = 0 } } })'';
          type = "viml";
        }
        {
          plugin = nvim-colorizer-lua;
          config = toLua ''
            vim.opt.termguicolors = true
            require("colorizer").setup()
          '';
          type = "viml";
        }
        {
          plugin = alpha-nvim;
          config = toLua ''require("alpha").setup(require("alpha.themes.startify").config)'';
          type = "viml";
        }

        ################
        # Editing Enhancements
        ################
        {
          plugin = nvim-surround;
          config = toLua ''require("nvim-surround").setup({})'';
          type = "viml";
        }
        {
          plugin = todo-comments-nvim;
          config = toLua ''require("todo-comments").setup({})'';
          type = "viml";
        }

        ################
        # Navigation
        ################
        {
          plugin = aerial-nvim;
          config = toLuaFile ./nvim/plugin/aerial.lua;
          type = "viml";
        }

        ################
        # Git Enhancements
        ################
        {
          plugin = lazygit-nvim;
          config = toLua ''vim.g.lazygit_floating_window_scaling_factor = 0.9'';
          type = "viml";
        }
        {
          plugin = diffview-nvim;
          config = toLua ''require("diffview").setup({})'';
          type = "viml";
        }

        ################
        # Utilities
        ################
        undotree
      ];

      initLua = ''
        -- Cutie Pro colorscheme (matches kitty/starship)
        ${builtins.readFile ./nvim/cutie-pro-theme.lua}

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
        vim.keymap.set('n', '<leader>xb', ':RustDiagToggle<CR>', { silent = true, desc = 'Toggle current-file diagnostics split' })
        vim.keymap.set('n', '<leader>xa', ':RustDiagAuto<CR>', { silent = true, desc = 'Toggle auto-opening of that split' })

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

        -- Rust (rustaceanvim). Harmless outside a Rust buffer.
        vim.keymap.set('n', '<leader>rr', ':RustLsp runnables<CR>', { silent = true, desc = 'Rust runnables' })
        vim.keymap.set('n', '<leader>rd', ':RustLsp debuggables<CR>', { silent = true, desc = 'Rust debuggables' })
        vim.keymap.set('n', '<leader>rt', ':RustLsp testables<CR>', { silent = true, desc = 'Rust testables' })
        vim.keymap.set('n', '<leader>re', ':RustLsp expandMacro<CR>', { silent = true, desc = 'Rust expand macro' })
        vim.keymap.set('n', '<leader>rE', ':RustLsp explainError<CR>', { silent = true, desc = 'Rust explain error (E0xxx)' })
        vim.keymap.set('n', '<leader>rl', ':RustLsp renderDiagnostic<CR>', { silent = true, desc = 'Rust diagnostic as cargo prints it' })
        vim.keymap.set('n', '<leader>rD', ':RustLsp openDocs<CR>', { silent = true, desc = 'Rust open docs.rs for symbol' })
        vim.keymap.set('n', '<leader>rk', ':RustLsp openCargo<CR>', { silent = true, desc = 'Rust open Cargo.toml' })
        vim.keymap.set('n', '<leader>rp', ':RustLsp parentModule<CR>', { silent = true, desc = 'Rust parent module' })
        vim.keymap.set('n', '<leader>rg', ':RustLsp crateGraph<CR>', { silent = true, desc = 'Rust crate graph' })
        vim.keymap.set('n', '<leader>rw', ':RustAnalyzer reloadWorkspace<CR>', { silent = true, desc = 'Rust reload workspace' })

        -- Cargo tasks (overseer)
        vim.keymap.set('n', '<leader>rc', ':CargoTask<CR>', { silent = true, desc = 'Run a cargo task' })
        vim.keymap.set('n', '<leader>rT', ':OverseerToggle<CR>', { silent = true, desc = 'Toggle task list' })
        vim.keymap.set('n', '<leader>rR', ':OverseerRun<CR>', { silent = true, desc = 'Overseer: run task' })

        -- Tests (neotest, backed by cargo-nextest via rustaceanvim)
        vim.keymap.set('n', '<leader>tn', function() require('neotest').run.run() end, { silent = true, desc = 'Test nearest' })
        vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, { silent = true, desc = 'Test current file' })
        vim.keymap.set('n', '<leader>tA', function() require('neotest').run.run(vim.uv.cwd()) end, { silent = true, desc = 'Test whole suite' })
        vim.keymap.set('n', '<leader>tl', function() require('neotest').run.run_last() end, { silent = true, desc = 'Re-run last test' })
        vim.keymap.set('n', '<leader>tx', function() require('neotest').run.stop() end, { silent = true, desc = 'Stop test run' })
        vim.keymap.set('n', '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, { silent = true, desc = 'Debug nearest test' })
        vim.keymap.set('n', '<leader>ts', function() require('neotest').summary.toggle() end, { silent = true, desc = 'Test summary panel' })
        vim.keymap.set('n', '<leader>to', function() require('neotest').output.open({ enter = true, auto_close = true }) end, { silent = true, desc = 'Test output' })
        vim.keymap.set('n', '<leader>tp', function() require('neotest').output_panel.toggle() end, { silent = true, desc = 'Test output panel' })
        vim.keymap.set('n', ']n', function() require('neotest').jump.next({ status = 'failed' }) end, { silent = true, desc = 'Next test failure' })
        vim.keymap.set('n', '[n', function() require('neotest').jump.prev({ status = 'failed' }) end, { silent = true, desc = 'Previous test failure' })


        -- Optional: if telescope-ui-select.nvim is installed, use it for vim.ui.select
        pcall(function()
          require("telescope").load_extension("ui-select")
        end)

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
  };
}
