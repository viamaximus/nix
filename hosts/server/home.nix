{
  pkgs,
  ...
}: {
  imports = [
    ../../homeManagerModules/shell/server.nix
    ../../homeManagerModules/shell/starship.nix
  ];

  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [
    curl
    fd
    git
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

    git = {
      enable = true;
      settings = {
        user.name = "viamaximus";
        user.email = "70414866+viamaximus@users.noreply.github.com";
      };
    };
  };

  home.stateVersion = "25.05";
}
