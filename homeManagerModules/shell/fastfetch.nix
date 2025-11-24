{...}: {
  programs.fastfetch.enable = true;

  programs.fastfetch.settings = {
    logo = {
      source = "nixos";
      padding = {
        right = 1;
      };
    };
    display = {
      size = {
        binaryPrefix = "si";
      };
      color = "blue";
      separator = "  ";
    };
    modules = [
      {
        type = "datetime";
        key = "Date";
        format = "{1}-{3}-{11}";
      }
      {
        type = "datetime";
        key = "Time";
        format = "{14}:{17}:{20}";
      }
      {
        key = "Distro";
        type = "os";
      }
      {
        key = "Kernel";
        type = "kernel";
      }
      {
        key = "Shell";
        type = "shell";
      }
      {
        key = "Packages";
        type = "packages";
      }
      {
        key = "WM";
        type = "wm";
      }
      {
        key = "CPU";
        type = "cpu";
      }
      {
        key = "Memory";
        type = "memory";
      }
      {
      }

      "break"
      "player"
      "media"
    ];
  };
}
