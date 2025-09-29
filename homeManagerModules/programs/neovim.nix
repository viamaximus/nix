{ lib, config, pkgs, ... }:
let
  vp    = pkgs.vimPlugins;
  hasVP = name: lib.hasAttr name vp;

  # Prefer modern LSP name; fall back if needed
  luaLsp =
    if pkgs ? lua-language-server
    then pkgs.lua-language-server
    else pkgs.luajitPackages.lua-lsp;

  isLinux = pkgs.stdenv.isLinux;

  # Comment.nvim attr varies in nixpkgs snapshots
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

    # IMPORTANT: use the same Neovim build HM targets
    # package = pkgs.neovim;

    viAlias      = true;
    vimAlias     = true;
    vimdiffAlias = true;

    # External CLI deps
    extraPackages =
      (with pkgs; [
        luaLsp
        ripgrep
        fd
      ]) ++ lib.optionals isLinux (with pkgs; [ wl-clipboard xclip ]);

    # Plugins. All requires are guarded.
    plugins = lib.filter (p: p != null) (with vp; [
      { plugin = nvim-autopairs; }
      commentEntry
      lualine-nvim
      nvim-web-devicons
      vim-nix

      { plugin = nvim-lspconfig; type = "lua"; config = builtins.readFile ./nvim/plugin/lsp.lua; }
      neodev-nvim

      { plugin = nvim-cmp;       type = "lua"; config = builtins.readFile ./nvim/plugin/cmp.lua; }
      cmp-nvim-lsp
      cmp_luasnip
      luasnip
      friendly-snippets

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

    extraLuaConfig = ''
      vim.opt.clipboard = "unnamedplus"
      vim.opt.termguicolors = true
      ${builtins.readFile ./nvim/options.lua}
    '';
  };
}

