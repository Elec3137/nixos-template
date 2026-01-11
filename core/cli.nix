{
  pkgs,
  ...
}:

{
  # use https://search.nixos.org/packages to find more packages
  environment.systemPackages = with pkgs; [
    helix
    yt-dlp
    trash-cli
    sshfs
    killall

    fd
    ripgrep
    dust

    iftop
    compsize

    delta
    python3

    nixfmt
    nixd

    gnupg

    ffmpeg
  ];

  # the command for your editor of choice
  environment.variables.EDITOR = "hx";

  # use Fish, the nicest shell :)
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  # avoid generating caches (enabled by fish) due to slowdowns during nixos-rebuild
  # this may degrade autocompletion
  documentation.man.generateCaches = false;

  # Terminal MUltipleXer
  programs.tmux = {
    enable = true;

    # this is a sin committed for ergonomics
    # since "1" and "0" are quite far apart on most keyboards
    baseIndex = 1;

    keyMode = "vi";

    # https://unix.stackexchange.com/questions/608142/whats-the-effect-of-escape-time-in-tmux
    escapeTime = 50;

    clock24 = true;

    extraConfig = /* sh */ ''
      set -g mouse on

      # open new shells in the same working directory
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      ###### STYLING

      set -g status-style 'fg=pink'

      setw -g window-status-style 'fg=pink bg=black'
      setw -g window-status-format ' #I #[fg=white]#W #[fg=pink]#F '

      setw -g window-status-current-style 'fg=black bg=pink'
      setw -g window-status-current-format ' #I #W #F '

      set -g message-style 'fg=black bg=pink'

      set -g mode-style 'fg=black bg=pink'

      set -g pane-border-style 'fg=grey'
      set -g pane-active-border-style 'fg=pink'
    '';
  };

  environment.shellAliases = {
    # make nixos-rebuild use sudo as needed
    # note that multiline-with-logs is only supported by lix
    nixos-rebuild = /* sh */ ''nixos-rebuild --ask-sudo-password --log-format multiline-with-logs'';

    # make nix-shell preserve the user's $SHELL
    nix-shell = /* sh */ ''nix-shell --command "export SHELL=$SHELL; $SHELL"'';
  };

  # avoid calling nix's command-not-found (doesn't work with flakes)
  # (disabled by default in nixpkgs since 25.11)
  programs.command-not-found.enable = false;
  # instead you can use:
  # programs.nix-index.enable = true;

  # enter dev env on cd
  programs.direnv = {
    enable = true;
    # hide extra logging, that isn't particularly useful
    # (for only using nix at least)
    settings.global.hide_env_diff = true;
  };

  # enable bat, cat replacement
  programs.bat = {
    enable = true;
    # settings.theme = "ansi";
    extraPackages = with pkgs.bat-extras; [
      # for syntax highlighting manual pages
      batman
    ];
  };

  programs.git = {
    enable = true;

    config = {
      init.defaultBranch = "main";
      core.compression = 9;
      credential.helper = "cache";

      push.autoSetupRemote = true;
      pull.ff = "only";
      merge.conflictStyle = "zdiff3";
      commit.verbose = true; # show diffs in commit editor

      core.pager = "delta"; # depends on pkgs.delta!
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true; # use n and N to move between diff sections
      delta.diff-highlight = true; # simpler mode, highlights inter-line changes
    };
  };

  # enable rust replacement for sudo; more sensible defaults
  security.sudo-rs.enable = true;
}
