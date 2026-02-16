{pkgs, config, ...}: {
  home.packages = with pkgs; [
    grc
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      ${pkgs.fastfetch}/bin/fastfetch

      # Function to prepend sudo to current or last command
      function prepend_sudo
        set -l cmd (commandline)
        if test -z "$cmd"
          commandline -r "sudo $history[1]"
        else
          commandline -r "sudo $cmd"
        end
      end

      # Bind Alt+S to prepend sudo
      bind \es prepend_sudo
    '';
    shellAliases = {
      n = "nvim";
      ".." = "cd .. ";
      "..." = "cd ../..";
      ff = "fastfetch";
	  c = "clear";

      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";

      #git stuffs
      gca = "git add -A && git commit -a";
      gp = "git push";
      gst = "git status -sb";
    };
    plugins = [
      # Enable grc for colorized command output
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
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
