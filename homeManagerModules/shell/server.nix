{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    grc
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    initContent = ''
      if [[ -n "$SSH_CONNECTION" && "$TERM" == "xterm-kitty" ]]; then
        export TERM=xterm-256color
      fi

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      export LESS_TERMCAP_mb=$'\e[1;32m'
      export LESS_TERMCAP_md=$'\e[1;32m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[1;4;31m'

      alias ls='ls --color=auto'
      alias grep='grep --color=auto'
      alias diff='diff --color=auto'
      alias ip='ip --color=auto'

      path+=("$HOME/.local/bin")
      export PATH
    '';

    shellAliases = {
      n = "nvim";
      ".." = "cd ..";
      "..." = "cd ../..";
      c = "clear";
      gst = "git status -sb";
      ll = "ls -la --color=auto";
      la = "ls -A --color=auto";
      l = "ls -CF --color=auto";
    };
  };

  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };
}
