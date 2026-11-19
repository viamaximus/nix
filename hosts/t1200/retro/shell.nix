# Shell look for the t1200: plain-ASCII prompt (the Toshiba font has no
# nerd-font glyphs), colours by ANSI name so they follow the terminal palette,
# and fastfetch laid out like a BIOS POST screen. Functionality (git, language
# versions, nix-shell, durations, vi-mode indicator) is kept.
{lib, ...}: let
  f = lib.mkOverride 40; # beats the shared module's mkForce
in {
  programs.starship.settings = {
    # The shared palette maps names like "green" to fixed hex values; a dummy
    # palette lets those names fall through to the terminal's ANSI colours.
    palette = f "t1200";
    palettes.t1200.phosphor = "yellow";

    format = f (lib.concatStrings [
      "[\\[](bright-black)$username$hostname[\\]](bright-black) "
      "$directory"
      "$git_branch$git_status"
      "$nix_shell$c$cpp$rust$golang$python$nodejs$bun$java$kotlin$lua"
      "$docker_context$conda"
      "$cmd_duration"
      "$line_break$character"
    ]);

    add_newline = f true;

    username = f {
      show_always = true;
      style_user = "bold";
      style_root = "bold red";
      format = "[$user]($style)";
    };
    hostname = f {
      ssh_only = false;
      style = "bold";
      format = "[@$hostname]($style)";
    };
    directory = f {
      style = "bold yellow";
      format = "[$path]($style)[$read_only]($read_only_style) ";
      read_only = " [RO]";
      truncation_length = 3;
      truncation_symbol = ".../";
    };
    git_branch = f {
      symbol = "git:";
      style = "green";
      format = "[$symbol$branch]($style) ";
    };
    git_status = f {
      style = "red";
      format = "([\\[$all_status$ahead_behind\\]]($style) )";
    };
    nix_shell = f {
      symbol = "nix:";
      style = "cyan";
      format = "[$symbol$state]($style) ";
    };
    docker_context = f {
      symbol = "docker:";
      style = "blue";
      format = "[$symbol$context]($style) ";
    };
    conda = f {
      symbol = "conda:";
      style = "blue";
      format = "[$symbol$environment]($style) ";
      ignore_base = false;
    };
    cmd_duration = f {
      min_time = 500;
      style = "bright-black";
      format = "[took $duration]($style) ";
    };
    character = f {
      success_symbol = "[>](bold)";
      error_symbol = "[>](bold red)";
      vimcmd_symbol = "[<](bold)";
      vimcmd_replace_one_symbol = "[<](bold magenta)";
      vimcmd_replace_symbol = "[<](bold magenta)";
      vimcmd_visual_symbol = "[<](bold yellow)";
    };
  } // lib.genAttrs ["c" "cpp" "rust" "golang" "python" "nodejs" "bun" "java" "kotlin" "lua"] (lang:
    f {
      symbol = "${lang}:";
      style = "blue";
      format =
        if lang == "python"
        then "[$symbol$version(\\($virtualenv\\))]($style) "
        else "[$symbol$version]($style) ";
    });

  programs.zsh.initContent = lib.mkAfter ''
    # ── t1200: no icon glyphs, retro previews ─────────────
    _auto_ls_chpwd() { eza --group-directories-first -a "$PWD" }
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=1 --color=always $realpath'
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || eza --color=always $realpath 2>/dev/null || echo $desc'
  '';

  programs.zsh.shellAliases = {
    # kitty kittens don't work inside cool-retro-term
    icat = lib.mkForce "chafa";
    guide = "t1200-guide";
  };

  # bat/fzf/eza follow the terminal's ANSI palette
  home.sessionVariables.BAT_THEME = "ansi";

  # BIOS POST layout; logo stays the NixOS one for now.
  programs.fastfetch.settings = {
    logo.color = {
      "1" = "yellow";
      "2" = "bright_yellow";
    };
    display = lib.mkForce {
      size.binaryPrefix = "iec";
      separator = " : ";
      color = {
        keys = "default";
        title = "bright_yellow";
        output = "yellow";
      };
    };
    modules = lib.mkForce [
      {
        type = "custom";
        format = "TOSHIBA T1200 PERSONAL COMPUTER  BIOS v1.20";
      }
      {
        type = "custom";
        format = "(C) Copyright Toshiba Corporation 1987. All rights reserved.";
      }
      "break"
      {
        type = "cpu";
        key = "Main Processor .....";
      }
      {
        type = "memory";
        key = "Memory Test ........";
        format = "{used} / {total} OK";
      }
      {
        type = "disk";
        key = "Fixed Disk 0 .......";
        folders = "/";
        format = "{size-used} / {size-total} ({filesystem})";
      }
      {
        type = "display";
        key = "Display Adapter ....";
        format = "{width}x{height} @ {refresh-rate}Hz";
      }
      {
        type = "battery";
        key = "Battery Pack .......";
        format = "{capacity} {status}";
      }
      {
        type = "os";
        key = "Operating System ...";
        format = "{name} {version-id}";
      }
      {
        type = "kernel";
        key = "Kernel .............";
        format = "{release}";
      }
      {
        type = "wm";
        key = "Window Manager .....";
      }
      {
        type = "shell";
        key = "Command Interpreter ";
      }
      {
        type = "packages";
        key = "Packages ...........";
      }
      {
        type = "uptime";
        key = "Uptime .............";
      }
      "break"
      {
        type = "custom";
        format = "Press <F1> to continue, <Ctrl-Alt-Esc> to enter SETUP";
      }
    ];
  };
}
