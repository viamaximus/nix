{ ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = { source = "nixos"; padding.right = 1; };
      display = {
        size.binaryPrefix = "si";
        color = "blue";
        separator = "  ";
      };
      modules = [
        { type = "datetime"; key = "Date"; format = "{1}-{3}-{11}"; }
        { type = "datetime"; key = "Time"; format = "{14}:{17}:{20}"; }
        { type = "os";       key = "Distro"; }
        { type = "kernel";   key = "Kernel"; }
        { type = "shell";    key = "Shell"; }
        { type = "packages"; key = "Packages"; }
        { type = "wm";       key = "WM"; }
        { type = "cpu";      key = "CPU"; }
        { type = "memory";   key = "Memory"; }
        { } "break" "player" "media"
      ];
    };
  };
}

