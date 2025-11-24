{pkgs, ...}: {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      #splash = false;
      preload = ["../../../current.jpg"];
      wallpaper = [", ../../../current.jpg"];
    };
  };
}
