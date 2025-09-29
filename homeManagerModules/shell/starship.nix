{ pkgs, lib, ... }:
{
  programs.starship.enable = true;
  programs.starship.enableTransience = true;  # works on fish

  programs.starship.settings = {
    "$schema" = "https://starship.rs/config-schema.json";

    format = lib.concatStrings [
      "[](surface0)"
      "$os"
      "$username"
      "[](bg:peach fg:surface0)"
      "$directory"
      "[](fg:peach bg:green)"
      "$git_branch"
      "$git_status"
      "[](fg:green bg:maroon)"
      "$c$rust$golang$nodejs$php$java$kotlin$haskell$python"
      "[](fg:maroon bg:blue)"
      "$docker_context"
      "[](fg:blue bg:purple)"
      "$time"
      "[ ](fg:purple)"
      "$line_break$character"   # <- fixed
    ];

    palette = "catppuccin_mocha";
    palettes.catppuccin_mocha = {
      red     = "#f38ba8";
      maroon  = "#eba0ac";
      peach   = "#fab387";
      green   = "#a6e3a1";
      blue    = "#89b4fa";
      lavender= "#b4befe";
      text    = "#cdd6f4";
      surface0= "#313244";
      base    = "#1e1e2e";
      mantle  = "#181825";
    };

    os = { disabled = false; style = "bg:surface0 fg:text"; };
    os.symbols = {
      Windows="󰍲"; Ubuntu="󰕈"; SUSE=""; Raspbian="󰐿"; Mint="󰣭"; Macos="";
      Manjaro=""; Linux="󰌽"; Gentoo="󰣨"; Fedora="󰣛"; Alpine=""; Amazon="";
      Android=""; Arch="󰣇"; Artix="󰣇"; CentOS=""; Debian="󰣚"; Redhat="󱄛"; RedHatEnterprise="󱄛";
    };

    username = {
      show_always = true;
      style_user = "bg:surface0 fg:text";
      style_root = "bg:surface0 fg:text";
      format = "[ $user ]($style)";
    };

    directory = {
      style = "fg:mantle bg:peach";
      format = "[ $path ]($style)";
      truncation_length = 3;
      truncation_symbol = "…/";
      substitutions = {
        "~" = " ~";
        ".dotfiles" = " .dotfiles";
        "dev" = "󰲋 dev";
        "Documents" = "󰈙 Documents";
        "Downloads" = " Downloads";
        "Music" = "󰝚 Music";
        "Pictures" = " Pictures";
      };
    };

    git_branch = { symbol=""; style="bg:maroon"; format="[[ $symbol $branch ](fg:base bg:green)]($style)"; };
    git_status = { style="bg:maroon"; format="[[($all_status$ahead_behind )](fg:base bg:green)]($style)"; };

    nodejs = { symbol="";  style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    c      = { symbol=" "; style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    rust   = { symbol="";  style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    golang = { symbol="";  style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    php    = { symbol="";  style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    java   = { symbol=" "; style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    kotlin = { symbol="";  style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    haskell= { symbol="";  style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };
    python = { symbol="";  style="bg:maroon"; format="[[ $symbol( $version) ](fg:base bg:maroon)]($style)"; };

    docker_context = { symbol=""; style="bg:mantle"; format="[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)"; };

    time = { disabled=false; time_format="%R"; style="bg:peach"; format="[[  $time ](fg:mantle bg:purple)]($style)"; };

    line_break.disabled = false;

    character = {
      disabled = false;
      success_symbol = "[](bold fg:green)";
      error_symbol   = "[](bold fg:red)";
      vimcmd_symbol  = "[](bold fg:green)";         # <- fixed
      vimcmd_replace_one_symbol = "[](bold fg:purple)";
      vimcmd_replace_symbol     = "[](bold fg:purple)";
      vimcmd_visual_symbol      = "[](bold fg:lavender)";
    };
  };
}

