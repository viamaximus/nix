{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    grc
  ];

  programs.zsh = {
    enable = true;

    # Enable autocompletion
    enableCompletion = true;

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
      # Run fastfetch on shell start
      ${pkgs.fastfetch}/bin/fastfetch

      # Better completion styling
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
      zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
      zstyle ':completion:*' group-name '''

      # Colored man pages
      export LESS_TERMCAP_mb=$'\e[1;32m'
      export LESS_TERMCAP_md=$'\e[1;32m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[1;4;31m'

      # Function to prepend sudo to current or last command (Alt+S)
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

      # Better keybindings
      bindkey '^[[A' history-search-backward  # Up arrow searches history
      bindkey '^[[B' history-search-forward   # Down arrow searches history
      bindkey '^[[1;5C' forward-word          # Ctrl+Right moves forward word
      bindkey '^[[1;5D' backward-word         # Ctrl+Left moves backward word
      bindkey '^[[H' beginning-of-line        # Home key
      bindkey '^[[F' end-of-line              # End key
      bindkey '^[[3~' delete-char             # Delete key

      # Enable colored output for ls and grep
      alias ls='ls --color=auto'
      alias grep='grep --color=auto'
      alias diff='diff --color=auto'
      alias ip='ip --color=auto'

      # Add paths
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

      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";

      # git stuffs
      gca = "git add -A && git commit -a";
      gp = "git push";
      gst = "git status -sb";

      # ls improvements with color
      ll = "ls -la --color=auto";
      la = "ls -A --color=auto";
      l = "ls -CF --color=auto";
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

  # Enable dircolors for colored ls output
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };
}
