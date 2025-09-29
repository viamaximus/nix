{ lib, config, pkgs, ... }:
let
  vp    = pkgs.vimPlugins;
  hasVP = name: lib.hasAttr name vp;

  # Prefer modern package name; fall back if needed
  luaLsp =
    if pkgs ? lua-language-server
    then pkgs.lua-language-server
    else pkgs.luajitPackages.lua-lsp;

  isLinux = pkgs.stdenv.isLinux;

  # Comment.nvim attr varies across nixpkgs
  commentPlugin =
    if hasVP "Comment-nvim" then vp."Comment-nvim"
    else if hasVP "comment-nvim" then vp.comment-nvim
    else null;

  commentEntry =
    if commentPlugin != null then {
      plugin = commentPlugin;
      type = "lua";
      config = ''
        local ok, C = pcall(require, "Comment")
        if ok then C.setup() end
      '';
    } else null;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias      = true;
    vimAlias     = true;
    vimdiffAlias = true;

    # External tools used by your config
    extraPackages =
      (with pkgs; [
        luaLsp
        ripgrep     # telescope live_grep
        fd          # telescope file finder
      ]) ++ lib.optionals isLinux (with pkgs; [
        wl-clipboard
        xclip
      ]);

    # Plugins; every require(...) is guarded
    plugins = lib.filter (p: p != null) (with vp; [
      # Editing / UX
      { plugin = nvim-autopairs; }
      commentEntry
      lualine-nvim
      nvim-web-devicons
      vim-nix

      # LSP
      { plugin = nvim-lspconfig; type = "lua"; config = builtins.readFile ./nvim/plugin/lsp.lua; }
      neodev-nvim

      # Completion
      { plugin = nvim-cmp;       type = "lua"; config = builtins.readFile ./nvim/plugin/cmp.lua; }
      cmp-nvim-lsp
      cmp_luasnip
      luasnip
      friendly-snippets

      # Telescope (+ dependency + fzf-native)
      plenary-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local ok = pcall(require, "telescope")
          if ok then
            ${builtins.readFile ./nvim/plugin/telescope.lua}
          end
        '';
      }
      {
        plugin = telescope-fzf-native-nvim;
        type = "lua";
        config = ''pcall(function() require("telescope").load_extension("fzf") end)'';
      }

      # Treesitter (guarded)
      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-bash
          p.tree-sitter-json
          p.tree-sitter-lua
          p.tree-sitter-nix
          p.tree-sitter-python
          p.tree-sitter-vim
        ]));
        type = "lua";
        config = ''
          local ok, configs = pcall(require, "nvim-treesitter.configs")
          if not ok then return end
          ${builtins.readFile ./nvim/plugin/treesitter.lua}
        '';
      }
    ]);

    # Global Lua appended after plugins
    extraLuaConfig = ''
      vim.opt.clipboard = "unnamedplus"
      vim.opt.termguicolors = true
      ${builtins.readFile ./nvim/options.lua}
    '';
  };
}

