{
  pkgs,
  ...
}:

{
  imports = [
    ./cli.nix
  ];

  # FIXME replace "XXX" with the username you'd like to use
  users.users.XXX = {
    isNormalUser = true;

    extraGroups = [
      "networkmanager" # leave this here if you use NetworkManager
      "wheel"
    ];

    # key(s) with which you'd like to have access to this user through SSH
    # FIXME replace the key here
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFy9h9uYLmuF/fXUHA+nYNPNwmLYXv+YZC1K7cX/lPul template"
    ];
  };

  # use lix, a fork of nix
  # see: https://lix.systems/about
  nix.package = pkgs.lixPackageSets.stable.lix;
  # overlays so that all nix tools use lix
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
  # only lix supports log-format: multiline-with-logs
  environment.shellAliases = {
    # also makes nixos-rebuild use sudo as needed (not lix exclusive)
    nixos-rebuild = /* sh */ ''nixos-rebuild --ask-sudo-password --log-format multiline-with-logs'';

    nix = /* sh */ ''nix --log-format multiline-with-logs'';
  };

  # enable useful nix tools, and the flakes system
  nix.settings.experimental-features = "nix-command flakes";
  # you (should) never need this
  nix.channel.enable = false;

  # reduces disk usage of the nix store
  # It does this by performing `nix store optimize` incrementally for each new path
  # source: https://nix.dev/manual/nix/2.26/command-ref/new-cli/nix3-store-optimise
  nix.settings.auto-optimise-store = true;

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

  # run fstrim monthly instead of weekly
  # weekly is unecessary for preventing long-term performance degredation
  # https://unix.stackexchange.com/questions/218076/ssd-how-often-should-i-do-fstrim
  services.fstrim.interval = "monthly";

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

  # disable the default display manager. (graphical login prompt at boot)
  # it is enabled by nixpkgs/nixos/modules/services/x11/xserver.nix
  # if you have services.xserver.enable = true set, which you may not want
  # especially if you use the xserver only for forwarding (ie with ssh)
  services.xserver.displayManager.lightdm.enable = false;

  services.openssh.enable = true;
  # only accept key authentication, for security
  services.openssh.settings.PasswordAuthentication = false;

  programs.java = {
    # enable = true;

    # build java with JavaFX gui library (likely requires compilation)
    # package = pkgs.jdk.override { enableJavaFX = true; };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ];
  # networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # leave this uncommented if you use any unfree packages/modules
  # even the "open" Nvidia drivers have proprietary userside components: https://wiki.nixos.org/wiki/NVIDIA
  nixpkgs.config.allowUnfree = true;

  # set your time zone if you need to
  # time.timeZone = null;

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
