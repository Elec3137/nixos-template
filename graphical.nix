{
  pkgs,
  ...
}:

{
  # if you use bluetooth
  hardware.bluetooth.enable = true;

  services = {
    # xserver.enable = true;
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
  
  # you can also automatically start plasma on the first TTY upon login
  # environment.interactiveShellInit = ''test $(tty) = /dev/tty1 && startplasma-wayland'';
  # If you're using Full Disk Encryption, you could enable autologin too
  # services.getty.autologinUser = "XXX"
  # services.getty.autologinOnce = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    ungoogled-chromium

    # video player
    haruna

    # office suite
    libreoffice-fresh

    # switch these based on your gpu
    btop-rocm
    nvtopPackages.amd

    # if you're using a wayland desktop;
    wl-clipboard
    wayland-utils

    # use easyeffects (gui) to filter noise from microphone
    easyeffects

    # performance overlay with fps control
    mangohud

    # encryption tool
    kdePackages.kleopatra
    # the password manager of choice
    keepassxc
    kdePackages.plasma5support # keepassxc requires plasma5support for classic theme to look right
    
    # torrenting client
    qbittorrent
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
    # enable = true;
    # this won't work until https://github.com/NixOS/nixpkgs/pull/394028
    # package = pkgs.ungoogled-chromium;
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

  # Steam (games)
  programs.steam = {
    enable = true;

    # open firewall to let these steam features work
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # add GE-Proton if it might help
    # extraCompatPackages = [ pkgs.proton-ge-bin ];

    # protontricks, a winetricks wrapper for proton
    # also includes protontricks-launch which allows you to launch apps in the selected steam game prefix
    # protontricks.enable = true;
  };
  environment.variables = {
    MANGOHUD = 1; # enable mangohud by default on all vulkan games
  };

  # Nvidia block; uncomment only for Nvidia GPUs
  # hardware.graphics.enable = true; # OpenGL
  # Load nvidia driver for Xorg and Wayland
  # services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
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
  };
}
