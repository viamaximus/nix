{ lib, config, pkgs, ... }:
let
  toLua      = str: "lua << 'EOF'\n${str}\nEOF\n";
  toLuaFile  = file: "lua << 'EOF'\n${builtins.readFile file}\nEOF\n";

  # Prefer the modern language server package name if available
  luaLsp =
    if pkgs ? lua-language-server
    then pkgs.lua-language-server
    else pkgs.luajitPackages.lua-lsp;

  isLinux  = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # External tools Neovim will call
    extraPackages =
      (with pkgs; [
        luaLsp
        ripgrep          # for telescope live_grep
      ])
      ++ lib.optionals isLinux (with pkgs; [
        wl-clipboard     # Wayland clipboard
        xclip            # X11 clipboard (harmless on Wayland)
      ]);

    # Plugins (Nix builds them; your per-plugin Lua lives under ./nvim/)
    plugins = with pkgs.vimPlugins; [
      # editing / UX
      { plugin = nvim-autopairs; }                # auto pairs
      { plugin = comment-nvim;   config = toLua ''require("Comment").setup()''; }
      lualine-nvim
      nvim-web-devicons
      vim-nix

      # LSP & Lua dev
      { plugin = nvim-lspconfig; config = toLuaFile ./nvim/plugin/lsp.lua; }
      neodev-nvim

      # completion
      { plugin = nvim-cmp;       config = toLuaFile ./nvim/plugin/cmp.lua; }
      cmp-nvim-lsp
      cmp_luasnip
      luasnip
      friendly-snippets

      # telescope (with native fzf)
      { plugin = telescope-nvim;            config = toLuaFile ./nvim/plugin/telescope.lua; }
      { plugin = telescope-fzf-native-nvim; config = toLua ''pcall(require("telescope").load_extension, "fzf")''; }

      # treesitter
      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-bash
          p.tree-sitter-json
          p.tree-sitter-lua
          p.tree-sitter-nix
          p.tree-sitter-python
          p.tree-sitter-vim
        ]));
        config = toLuaFile ./nvim/plugin/treesitter.lua;
      }
    ];

    # Global Lua appended after plugins load
    extraLuaConfig = ''
      -- sane defaults you likely already have in ./nvim/options.lua,
      -- but keep a couple here to ensure host portability.
      vim.opt.clipboard = "unnamedplus"   -- use system clipboard on all hosts
      vim.opt.termguicolors = true

      -- Load your existing options file
      ${builtins.readFile ./nvim/options.lua}
    '';
  };
}

