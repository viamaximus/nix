{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    grc
    zsh-fzf-tab
    zsh-you-should-use
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
      # --- Fastfetch with auto-clear on first command ---
      ${pkgs.fastfetch}/bin/fastfetch

      _fastfetch_clear_preexec() {
        clear
        preexec_functions=("''${(@)preexec_functions:#_fastfetch_clear_preexec}")
      }
      preexec_functions+=(_fastfetch_clear_preexec)

      # --- fzf-tab (must be after compinit, before widget wrapping) ---
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # --- zsh-you-should-use ---
      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh

      # --- Auto-list directory contents on cd ---
      _auto_ls_chpwd() {
        eza -a "$PWD"
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

      # --- Keybindings ---
      bindkey '^[[A' history-search-backward  # Up arrow searches history
      bindkey '^[[B' history-search-forward   # Down arrow searches history
      bindkey '^[[1;5C' forward-word          # Ctrl+Right moves forward word
      bindkey '^[[1;5D' backward-word         # Ctrl+Left moves backward word
      bindkey '^[[H' beginning-of-line        # Home key
      bindkey '^[[F' end-of-line              # End key
      bindkey '^[[3~' delete-char             # Delete key

      # --- Colored output ---
      alias grep='grep --color=auto'
      alias diff='diff --color=auto'
      alias ip='ip --color=auto'

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
      gp = "git push";
      gst = "git status -sb";

      # eza aliases
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      l = "eza";
      lt = "eza --tree --level=2";
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
