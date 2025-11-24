{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    
    settings = {
      # Simple, clean format
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$character"
      ];
      
      add_newline = true;
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[⟨](bold green)";
      };
      
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        format = "[$path](\$style) ";
        style = "bold cyan";
        read_only = " 󰌾";
        home_symbol = "~";
      };
      
      git_branch = {
        symbol = " ";
        format = "on [$symbol$branch](\$style) ";
        style = "bold purple";
      };
      
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]](\$style) )";
        style = "bold red";
      };
      
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow) ";
      };
    };
  };
}
