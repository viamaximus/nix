{ pkgs, ... }:{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      ${pkgs.fastfetch}/bin/fastfetch
    '';
    shellAliases = {
      n = "nvim";
      ".." = "cd .. ";
      "..." = "cd ../..";
      ff = "fastfetch";

      #this will need updated in order to work on other hosts
      rebuild = "sudo nixos-rebuild switch --flake .#asus-zephyrus";
      
      #git stuffs
      gca = "git commit -a";

    };
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      #{ name = "grc"; src = pkgs.fishPlugins.grc.src; }
      # Manually packaging and enable a plugin
      #{
      #  name = "z";
      #  src = pkgs.fetchFromGitHub {
      #    owner = "jethrokuan";
      #    repo = "z";
      #    rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
      #    sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
      #  };
      #}
    ];
  };
}
