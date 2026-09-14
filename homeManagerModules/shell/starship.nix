{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;

    # Bypass Nix TOML serializer which strips Private Use Area Unicode chars
    # (powerline arrows U+E0B0 etc.) — write TOML directly
    settings = {
      palette = lib.mkForce "cutie_pro";

      format = lib.mkForce (builtins.fromJSON ''"[\ue0b6](fg:red)$os$username$hostname[\ue0b0](bg:peach fg:red)$directory[\ue0b0](bg:yellow fg:peach)$git_branch$git_status[\ue0b0](fg:yellow bg:green)$c$cpp$rust$golang$nodejs$bun$python$java$kotlin$lua$nix_shell[\ue0b0](fg:green bg:sapphire)$docker_context$conda[\ue0b0](fg:sapphire bg:lavender)$time[\ue0b4](fg:lavender)$cmd_duration $character"'');

      add_newline = true;

      os = {
        disabled = false;
        style = "bg:red fg:crust";
        symbols = {
          NixOS = "󱄅 ";
          Macos = "󰀵 ";
          Linux = "󰌽 ";
          Gentoo = "󰣨 ";
          Fedora = "󰣛 ";
          Alpine = " ";
          Arch = "󰣇 ";
          Artix = "󰣇 ";
          CentOS = " ";
          Debian = "󰣚 ";
          Redhat = "󱄛 ";
          RedHatEnterprise = "󱄛 ";
          Ubuntu = "󰕈 ";
          Mint = "󰣭 ";
          Manjaro = " ";
          SUSE = " ";
          Raspbian = "󰐿 ";
          Windows = " ";
          Amazon = " ";
          Android = " ";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:red fg:crust";
        style_root = "bg:red fg:crust bold";
        format = "[ $user]($style)";
      };

      hostname = {
        ssh_only = false;
        style = "bg:red fg:crust";
        format = "[@$hostname ]($style)";
      };

      directory = {
        style = "bg:peach fg:crust";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = ".../";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = "󰝚 ";
          Pictures = " ";
          Developer = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:yellow";
        format = builtins.fromJSON ''"[[ $symbol $branch ](fg:crust bg:yellow)]($style)"'';
      };

      git_status = {
        style = "bg:yellow";
        format = builtins.fromJSON ''"[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)"'';
      };

      c = {
        symbol = " ";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      cpp = {
        symbol = " ";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      rust = {
        symbol = "";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      golang = {
        symbol = "";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      nodejs = {
        symbol = "";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      bun = {
        symbol = "";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      python = {
        symbol = "";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version)(\\($virtualenv\\)) ](fg:crust bg:green)]($style)"'';
      };

      java = {
        symbol = " ";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      kotlin = {
        symbol = "";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      lua = {
        symbol = "";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol( $version) ](fg:crust bg:green)]($style)"'';
      };

      nix_shell = {
        symbol = "󱄅";
        style = "bg:green";
        format = builtins.fromJSON ''"[[ $symbol $state ](fg:crust bg:green)]($style)"'';
      };

      docker_context = {
        symbol = "";
        style = "bg:sapphire";
        format = builtins.fromJSON ''"[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)"'';
      };

      conda = {
        symbol = "  ";
        style = "fg:crust bg:sapphire";
        format = "[$symbol$environment ]($style)";
        ignore_base = false;
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender";
        format = builtins.fromJSON ''"[[ \ue0b1 $time ](fg:crust bg:lavender)]($style)"'';
      };

      cmd_duration = {
        min_time = 500;
        format = " in $duration ";
        disabled = false;
      };

      line_break = {
        disabled = false;
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
        vimcmd_replace_symbol = "[❮](bold fg:lavender)";
        vimcmd_visual_symbol = "[❮](bold fg:yellow)";
      };

      # Same Cutie Pro scheme as kitty/neovim, mapped onto this template's slot names by hue.
      palettes.cutie_pro = {
        red = "#f56e7f";
        peach = "#f58669";
        yellow = "#e8d6a7"; # tan (closest to yellow)
        green = "#37cb8a";
        sapphire = "#42d9c5"; # teal
        lavender = "#b294bb"; # mauve
        crust = "#181818"; # background, used as fg text on bright segments
      };
    };
  };
}
