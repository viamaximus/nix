{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Only the base modules - no optional/heavy packages
    ../../homeManagerModules
  ];

  # No desktop features - using GNOME from system configuration
  stylix.targets.firefox.profileNames = ["default"];

  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {};

  # GNOME keyboard shortcuts to match Hyprland
  dconf.settings = {
    # Fixed workspaces
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };

    # Window management
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      toggle-fullscreen = ["<Super>f"];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
    };

    # Disable GNOME's Super+N app switching (conflicts with workspace switching)
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
      switch-to-application-2 = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
      switch-to-application-3 = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
      switch-to-application-4 = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
      show-screenshot-ui = ["<Super><Shift>s"];
    };

    # Lock screen
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = ["<Super><Shift>l"];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };

    # Custom app launchers
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "kitty";
      binding = "<Super>Return";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Browser";
      command = "zen-beta";
      binding = "<Super>b";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "File Manager";
      command = "nautilus";
      binding = "<Super>e";
    };
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
