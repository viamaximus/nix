{ lib, config, pkgs, ... }:
let
  hasVP = name: lib.hasAttr name pkgs.vimPlugins;
  vp = pkgs.vimPlugins;

  luaLsp =
    if pkgs ? lua-language-server
    then pkgs.lua-language-server
    else pkgs.luajitPackages.lua-lsp;

  isLinux = pkgs.stdenv.isLinux;

  commentPlugin =
    if hasVP "Comment-nvim" then vp."Comment-nvim"
    else if hasVP "comment-nvim" then vp.comment-nvim
    else null;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true; vimAlias = true; vimdiffAlias = true;

    extraPackages =
      (with pkgs; [
        luaLsp
        ripgrep
        fd
      ]) ++ lib.optionals isLinux (with pkgs; [ wl-clipboard xclip ]);

    plugins = lib.filter (p: p != null) (with vp; [
      { plugin = nvim-autopairs; }

      # Comment.nvim (guarded)
      {
        plugin = commentPlugin;
        type = "lua";
        config = ''
          local ok, C = pcall(require, "Comment")
          if ok then C.setup() end
        '';
      }

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

      # Telescope (+ dependency + fzf)
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
          local ok, _ = pcall(require, "nvim-treesitter.configs")
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

