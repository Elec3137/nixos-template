{
  pkgs,
  ...
}:

{
  imports = [
    # if you seperate configuration.nix into other files, add them here
  ];

  # use lix, a fork of nix
  # see: https://lix.systems/about
  nix.package = pkgs.lixPackageSets.stable.lix;
  # overlays so that all nix tools use lix
  nixpkgs.overlays = [ (final: prev: {
    inherit (prev.lixPackageSets.stable)
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena;
  }) ];

  # enable useful nix tools, and the flakes system
  nix.settings.experimental-features = "nix-command flakes";
  # make sure to always specify "--flake /etc/nixos#HOSTNAME" on rebuild
  # replace "HOSTNAME" with your system's hostname, reflected in flake.nix
  # example: `sudo nixos-rebuild switch --flake /etc/nixos#nixos`

  # NixOS uses the lts kernel by default, override it with the latest if you need to
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # tweak btrfs compression
  # 3 is the default, 1 is minimal, 8 is good if you have a decent CPU or a slower drive
  # fileSystems."/".options = [ "compress=zstd:8" ];

  boot.loader = {
    # if you're using a standard uefi
    # if this doesn't work, off to the wiki you go :)
    efi.canTouchEfiVariables = true;

    # systemd-boot is the standard
    systemd-boot.enable = true;
    # OR if you have a limited efi partition, set the efi mount point to /boot/efi
    # efi.efiSysMountPoint = "/boot/efi"; # make sure your mount point defined in hardware-configuation.nix aligns with this
    # however systemd-boot does not support this configuration, so use grub instead
    grub = {
      # enable = true;
    
      # modern installation
      device = "nodev";
      efiSupport = true;

      # if your /boot partition is encrypted, enable this
      # grub takes a long time to unlock a partition though, so this is undesirable
      # and you might also need to embed the key into initramfs to avoid needing to enter the password twice
      # enableCryptodisk = true;

      # keep the grub background black
      splashImage = null;

      # look for other efi entries and add them to the boot menu
      useOSProber = true;

      # extra grub entry for memory testing
      memtest86.enable = true;
    };
  };

  # use tmpfs for /tmp to minimize disk wear
  # consider disabling if you have very limited memory
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "70%";
  };

  # extra memory if you can spare the CPU cycles
  zramSwap = {
    enable = true;
    # this is the amount of uncompressed data that can be swapped out
    # practical maximum is 150%
    memoryPercent = 100;
  };

  networking = {
    hostName = "nixos"; # also change hostname in flake if you use them

    # NetworkManager is required for most of the network managment used by desktop enviroments
    # also offers commandline interface accessable as "nmcli"
    networkmanager.enable = true;
    # alternatively, there is wpa_supplicant, a much simpler system
    # wireless.enable = true;
    # wireless.networks = {
    #   NETWORK_NAME = {
    #     psk = "PASSWORD";
    #   };
    # };
  };

  # use Fish, the nicest shell :)
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  # avoid calling nix's command-not-found (doesn't work with flakes)
  programs.command-not-found.enable = false;
  # add alias for managing user dotfiles "dots"
  programs.fish.interactiveShellInit = ''
    alias dots 'git --git-dir=$HOME/.dots/ --work-tree=$HOME'
    alias nixos-rebuild 'nixos-rebuild --flake /etc/nixos#$(hostname -s) --ask-sudo-password --log-format multiline-with-logs'
  '';
  # avoid generating caches (enabled by fish) due to slowdowns during nixos-rebuild
  # may degrade autocompletion
  documentation.man.generateCaches = false;

  # enable bat, cat replacement
  # mostly for syntax highlighting manual pages
  programs.bat = {
    enable = true;
    # settings.theme = "ansi";
    extraPackages = with pkgs.bat-extras; [
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

  # FIXME Remember to set your time zone!
  time.timeZone = "";

  # disable the default display manager (graphical login prompt at boot)
  services.xserver.displayManager.lightdm.enable = false;
  # OR use sddm
  # services.displayManager.sddm.enable = true;

  # FIXME replace "nixuser" with the username you'd like to use
  users.users.nixuser = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager" # leave this here if you use NetworkManager
      "wheel"
    ];

    # uncomment and add to this list ssh public keys you want to be able to connect to this user
    # openssh.authorizedKeys.keys = [ ];

    # you can specify user-specific packages here:
    # packages = with pkgs; [];
  };

  # enable rust replacement for sudo; more sensible defaults
  security.sudo-rs.enable = true;

  services.openssh.enable = true;
  # only accept key authentication, for security
  services.openssh.settings.PasswordAuthentication = false;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/packages to find more packages
  environment.systemPackages = with pkgs; [
    # cli tools
    helix
    tmux
    yt-dlp
    libjxl
    trash-cli
    sshfs
    killall
    # rust replacements for coreutils
    fd
    ripgrep
    dust
    # informational
    iftop
    compsize

    # development
    delta
    python3
    # rust
    rustc
    cargo
    rust-analyzer
    rustfmt
    # shell(s)
    fish-lsp
    bash-language-server
    # C/C++
    gcc
    clang
    clang-analyzer
    clang-tools
    # nix
    nixfmt
    nixd

    # encryption
    gnupg

    # for video encoding/decoding, and all else ffmpeg does
    ffmpeg
  ];

  environment.variables = {
    EDITOR = "hx"; # replace this with the command for your editor of choice
  };

  # Java, if needed
  # programs.java.enable = true;
  # build java with JavaFX gui library
  # programs.java.package = pkgs.jdk.override { enableJavaFX = true; };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ];
  # networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # leave this uncommented if you use any unfree packages/modules
  # even the "open" Nvidia drivers have proprietary userside components: https://wiki.nixos.org/wiki/NVIDIA
  nixpkgs.config.allowUnfree = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
