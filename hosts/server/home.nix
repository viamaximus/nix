{
  pkgs,
  ...
}: {
  imports = [
    ../../homeManagerModules/shell/server.nix
    ../../homeManagerModules/shell/starship.nix
    ../../homeManagerModules/programs/git.nix
  ];

  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [
    curl
    fd
    git
    gh
    jq
    lazygit
    neovim
    ripgrep
    tmux
    tree
    wget
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs = {
    btop.enable = true;
    eza.enable = true;
    home-manager.enable = true;
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = "mouse on";
    };
  };

  home.stateVersion = "25.05";
}
