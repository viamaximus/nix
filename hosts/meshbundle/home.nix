{pkgs, ...}: {
  imports = [
    ../../homeManagerModules/shell/server.nix
    ../../homeManagerModules/shell/starship.nix
    ../../homeManagerModules/programs/git.nix
    ../../homeManagerModules/programs/ssh.nix
  ];

  home.username = "mesh";
  home.homeDirectory = "/home/mesh";

  home.packages = with pkgs; [
    curl
    fd
    gh
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
  };

  home.stateVersion = "25.05";
}
