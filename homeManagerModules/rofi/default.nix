{
  pkgs,
  config,
  ...
}:{
  home.file.".config/rofi"= {
    source = ./configs;
    #copies scripts directory recurisve
    recursive = true;
    };
}
