{
  pkgs,
  inputs,
  hostInventory,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../nixosModules/terminal.nix
    ../../nixosModules/networking.nix
    ../../nixosModules/nix-settings.nix
    ../../nixosModules/ssh-web-keys.nix
    ../../nixosModules/agenix.nix
    ../../nixosModules/secrets.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs hostInventory;};
    users.max = import ./home.nix;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      devices = ["nodev"];
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "server";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.zsh.enable = true;
  services.openssh.enable = true;

  viamaximus.sshWebKeys.enable = true;

  users.users.max = {
    isNormalUser = true;
    description = "max";
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel"];
  };

  system.stateVersion = "25.05";
}
