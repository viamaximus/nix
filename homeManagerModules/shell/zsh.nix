{
  pkgs,
  config,
  lib,
  ...
}: let
  zsh-auto-notify = pkgs.fetchFromGitHub {
    owner = "MichaelAquilina";
    repo = "zsh-auto-notify";
    rev = "0.10.1";
    hash = "sha256-l5nXzCC7MT3hxRQPZv1RFalXZm7uKABZtfEZSMdVmro=";
  };
in {
  home.packages = with pkgs; [
    grc
    zsh-fzf-tab
    zsh-you-should-use
    zsh-autopair
    zsh-history-substring-search
    zsh-completions
    zsh-nix-shell
    zsh-forgit
    zsh-vi-mode
  ];

  programs.zsh = {
    enable = true;

    # Enable autocompletion
    enableCompletion = true;

    # Include zsh-completions in fpath before compinit
    completionInit = ''
      fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
      autoload -U compinit && compinit
    '';

    # Syntax highlighting (colors commands as you type)
    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "cursor"];
      styles = {
        # Commands
        command = "fg=green,bold";
        builtin = "fg=green,bold";
        alias = "fg=green,bold";

        # Arguments and paths
        path = "fg=cyan,underline";
        globbing = "fg=magenta";

        # Strings and quotes
        single-quoted-argument = "fg=yellow";
        double-quoted-argument = "fg=yellow";

        # Errors
        unknown-token = "fg=red,bold";
        reserved-word = "fg=magenta,bold";

        # Options
        single-hyphen-option = "fg=blue";
        double-hyphen-option = "fg=blue";
      };
    };

    # Fish-like autosuggestions (grayed out suggestions based on history)
    autosuggestion = {
      enable = true;
      strategy = ["history" "completion"];
    };

    # History settings
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    # Shell options
    initContent = ''
      # --- Fastfetch with auto-clear on first command ---
      ${pkgs.fastfetch}/bin/fastfetch

      _fastfetch_clear_preexec() {
        clear
        preexec_functions=("''${(@)preexec_functions:#_fastfetch_clear_preexec}")
      }
      preexec_functions+=(_fastfetch_clear_preexec)

      # --- Vi mode (must be sourced early, resets keybindings) ---
      ZVM_INIT_MODE=sourcing
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      # --- fzf-tab (must be after compinit, before widget wrapping) ---
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # --- Plugins ---
      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
      source ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh
      source ${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
      source ${pkgs.zsh-nix-shell}/share/zsh/plugins/zsh-nix-shell/nix-shell.plugin.zsh
      source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh
      source ${zsh-auto-notify}/auto-notify.plugin.zsh
      AUTO_NOTIFY_THRESHOLD=10
      AUTO_NOTIFY_IGNORE=("nvim" "vim" "ssh" "man" "less" "top" "htop" "btop" "tmux" "watch")

      # --- Auto-list directory contents on cd ---
      _auto_ls_chpwd() {
        eza --icons=auto --group-directories-first -a "$PWD"
      }
      chpwd_functions+=(_auto_ls_chpwd)

      # --- Completion styling ---
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
      zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
      zstyle ':completion:*' group-name '''

      # --- fzf-tab styling ---
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=1 --icons --color=always $realpath'
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || eza --icons --color=always $realpath 2>/dev/null || echo $desc'
      zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
      zstyle ':fzf-tab:*' switch-group ',' '.'

      # --- Colored man pages ---
      export LESS_TERMCAP_mb=$'\e[1;32m'
      export LESS_TERMCAP_md=$'\e[1;32m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[1;4;31m'

      # --- Sudo prepend (Alt+S) ---
      prepend_sudo() {
        if [[ -z "$BUFFER" ]]; then
          BUFFER="sudo $(fc -ln -1)"
        else
          BUFFER="sudo $BUFFER"
        fi
        CURSOR=$#BUFFER
      }
      zle -N prepend_sudo
      bindkey '\es' prepend_sudo

      # --- Keybindings (after vi-mode so they aren't overwritten) ---
      bindkey '^[[A' history-substring-search-up    # Up arrow: substring history search
      bindkey '^[[B' history-substring-search-down  # Down arrow: substring history search
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down
      bindkey '^[[1;5C' forward-word          # Ctrl+Right moves forward word
      bindkey '^[[1;5D' backward-word         # Ctrl+Left moves backward word
      bindkey '^[[H' beginning-of-line        # Home key
      bindkey '^[[F' end-of-line              # End key
      bindkey '^[[3~' delete-char             # Delete key

      # --- pay-respects (command correction) ---
      eval "$(${pkgs.pay-respects}/bin/pay-respects zsh --alias f)"

      # --- Shell functions ---
      mkcd() { mkdir -p "$1" && cd "$1" }

      extract() {
        if [[ -f "$1" ]]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "cannot extract '$1'" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # --- Colored output ---
      alias grep='grep --color=auto'
      alias diff='diff --color=auto'
      alias ip='ip --color=auto'

      # --- nix develop: use zsh instead of bash ---
      export NIX_BUILD_SHELL=zsh

      # --- Paths ---
      path+=("$HOME/.npm-global/bin")
      path+=("$HOME/.local/bin")
      export PATH
    '';

    shellAliases = {
      n = "nvim";
      ".." = "cd ..";
      "..." = "cd ../..";
      ff = "fastfetch";
      c = "clear";
      bt = "blutuith";
      cat = "bat --paging=never";

      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";

      # git stuffs
      gca = "git add -A && git commit -a";
      gcm = "git commit -m";
      gp = "git push";
      gpl = "git pull";
      gst = "git status -sb";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --oneline --graph --decorate -20";
      gla = "git log --oneline --graph --decorate --all -30";

      # eza aliases
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      lah = "eza -lah";
      l = "eza";
      lt = "eza --tree --level=2";

      # clipboard (wayland)
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";

      # kitty kittens
      icat = "kitten icat";
      kdiff = "kitten diff";
      kssh = "kitten ssh";
      hg = "kitten hyperlinked_grep";
    };

    # Oh-my-zsh plugins for extra functionality
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git" # Git aliases and completions
        "colored-man-pages" # Colored man pages
        "command-not-found" # Suggests packages when command not found
        "sudo" # Press ESC twice to prepend sudo
        "dirhistory" # Alt+Left/Right to navigate directory history
      ];
    };
  };

  # --- fzf with fd backend ---
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--info=inline"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --level=2 --icons --color=always {} | head -50'"
    ];
  };

  # --- zoxide (replaces cd with smart matching) ---
  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
  };

  # --- bat (syntax-highlighted cat) ---
  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };

  # Enable dircolors for colored ls output
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };
}
