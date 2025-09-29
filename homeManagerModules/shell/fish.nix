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
      
      #git stuffs
      gca = "git add -A && git commit -a";
      gp = "git push";
      gst = "git status -sb";

      hm = "home-manager switch --flake .";
      nr = "sudo nixos-rebuild switch --flake .";
    };
  };
}
