{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuation.nix
    # if you seperate configuration.nix into other files, add them here
  ];
  
  # if you use bluetooth
  hardware.bluetooth.enable = true;

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
    # if you have a limited efi partition, use grub instead
    # be careful if your /boot folder is encrypted
    # grub.enable = true;
    # grub.useOSProber = true;
    # grub.splashImage = null;
    # grub.device = "nodev";
    # efi.efiSysMountPoint = "/boot/efi"; # make sure your mount point defined in hardware-configuation.nix aligns with this
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

  services = {
    xserver.enable = true;
    # your desktop enviroment of choice
    desktopManager.plasma6.enable = true;

    # Enable sound.
    # pulseaudio.enable = true;
    # OR
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  # remove plasma6 packages you don't want
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
    elisa
    plasma-browser-integration
    plasma-workspace-wallpapers
    kwin-x11
    krdp
  ];
  # use kdeconnect (opens ports)
  programs.kdeconnect.enable = true;
  
  xdg.portal.enable = true;

  # use Fish, the nicest shell :)
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  # avoid calling nix's command-not-found (doesn't work with flakes)
  programs.command-not-found.enable = false;
  # display nix-shell packages on the right
  # and add alias for managing user dotfiles "dots"
  programs.fish.interactiveShellInit = ''
    ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    alias dots '${pkgs.git}/bin/git --git-dir=$HOME/.dots/ --work-tree=$HOME'
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

  # FIXME Remember to set your time zone!
  time.timeZone = "";

  # disable the default display manager (graphical login prompt at boot)
  services.xserver.displayManager.lightdm.enable = false;
  # OR use sddm
  # services.displayManager.sddm.enable = true;

  # you can also automatically start plasma on the first TTY upon login
  # environment.interactiveShellInit = ''test $(tty) = /dev/tty1 && startplasma-wayland'';
  # If you're using Full Disk Encryption, you could enable autologin too
  # services.getty.autologinUser = "XXX"
  # services.getty.autologinOnce = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
    # video player
    haruna

    # office suite
    libreoffice-fresh

    # cli tools
    helix
    tmux
    yt-dlp
    libjxl
    trash-cli
    vulkan-tools
    sshfs
    # rust replacements for coreutils
    fd
    ripgrep
    dust
    # informational
    iftop
    compsize
    # switch these based on your gpu
    btop-rocm
    nvtopPackages.amd

    # development
    git
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
    any-nix-shell

    # if you're using a wayland desktop;
    wl-clipboard
    wayland-utils

    # use easyeffects (gui) to filter noise from microphone
    easyeffects

    # performance overlay with fps control
    mangohud

    # encryption tools
    gnupg
    kdePackages.kleopatra
    # the password manager of choice
    keepassxc
    kdePackages.plasma5support # keepassxc requires plasma5support for classic theme to look right

    # torrenting client
    qbittorrent

    # for video encoding/decoding, and all else ffmpeg does
    ffmpeg
  ];

  programs.firefox = {
    # enable = true;
    package = pkgs.librewolf;
    preferences = {
      "privacy.resistFingerprinting" = false; # due to it forcing light theme
      "webgl.disabled" = false;

      # these should only be on by the user's request
      "privacy.clearHistory.cookiesAndStorage" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false; # this one seems to be the normal setting
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "mnjggcdmjocbbbhaepdhchncahnbgone" # sponsorblock
      # "ocaahdebbfolfmndjeplogmgcagdmblk" # chromium web store extension for updating other extensions on chromium
    ];
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://www.startpage.com/sp/search?query={searchTerms}&cat=web&pl=opensearch&language=english";
    defaultSearchProviderSuggestURL = "https://www.startpage.com/osuggestions?q={searchTerms}";
  };

  # fcitx input method
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc # japanese module
        fcitx5-gtk
      ];
    };
  };

  # enable waydroid, a container-based solution to android emulation
  # virtualisation.waydroid.enable = true;

  # enable Steam (games)
  programs.steam.enable = true;

  # add GE-Proton if it might help
  # programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  # protontricks, a winetricks wrapper for proton
  # also includes protontricks-launch which allows you to launch apps in the selected steam game prefix
  # programs.steam.protontricks.enable = true;

  environment.variables = {
    MANGOHUD = 1; # enable mangohud by default on all vulkan games
    EDITOR = "hx"; # replace this with the command for your editor of choice
    BROWSER = "chromium"; # your browser of choice
  };
  
  # Java, if needed
  # programs.java.enable = true;
  # build java with JavaFX gui library
  # programs.java.package = pkgs.jdk.override { enableJavaFX = true; };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # leave this uncommented if you use any unfree packages/modules
  # even the "open" Nvidia drivers have proprietary userside components: https://wiki.nixos.org/wiki/NVIDIA
  nixpkgs.config.allowUnfree = true;

  # Nvidia block; uncomment only for Nvidia GPUs
  # hardware.graphics.enable = true; # OpenGL
  # Load nvidia driver for Xorg and Wayland
  # services.xserver.videoDrivers = ["nvidia"];
  # hardware.nvidia = {
    # Modesetting is required.
    # modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    # powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # open = false;

    # Enable the Nvidia settings menu,
  	# accessible via `nvidia-settings`.
    # nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

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
