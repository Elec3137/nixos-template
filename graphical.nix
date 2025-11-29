{
  pkgs,
  ...
}:

{
  # if you use bluetooth
  hardware.bluetooth.enable = true;

  services = {
    # enable the standard sound system
    pipewire = {
      enable = true;
      # enable backwards compatibility with legacy sound system
      pulse.enable = true;
    };
    # OR enable the legacy sound system
    # pulseaudio.enable = true;

    # my personal favorite Desktop Enviroment
    desktopManager.plasma6.enable = true;

    # the standard KDE display manager (graphical login prompt)
    displayManager.sddm.enable = true;

    # If you're using Full Disk Encryption, you could enable autologin in the shell instead
    # getty.autologinUser = "XXX";
    # getty.autologinOnce = true;
  };
  # if you're not using a display manager, you can automatically start plasma on the first TTY upon login
  # environment.interactiveShellInit = ''test $(tty) = /dev/tty1 && startplasma-wayland'';

  # remove plasma6 packages you don't want
  # from optionalPackages defined in nixos/modules/services/desktop-managers/plasma6.nix
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-workspace-wallpapers
    kwin-x11
    elisa
    krdp
  ];
  # use kdeconnect (opens ports)
  programs.kdeconnect.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    ungoogled-chromium

    # videos
    haruna
    kdePackages.kdenlive

    # office suite
    libreoffice-qt-fresh

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

    vulkan-tools

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
    enable = true;

    # this won't work until https://github.com/NixOS/nixpkgs/pull/394028
    # package = pkgs.ungoogled-chromium;

    # note: you cannot use policies to install extensions on ungoogled-chromium
    # https://github.com/ungoogled-software/ungoogled-chromium/issues/1629
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin *not working?)
      "mnjggcdmjocbbbhaepdhchncahnbgone" # sponsorblock
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      # "ocaahdebbfolfmndjeplogmgcagdmblk" # chromium web store extension for updating other extensions on chromium
    ];
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://www.startpage.com/sp/search?query={searchTerms}";
    defaultSearchProviderSuggestURL = "https://www.startpage.com/osuggestions?q={searchTerms}";
  };

  # fcitx input method editor
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc # japanese module
        fcitx5-gtk
      ];

      settings.globalOptions = {
        # also require "alt" for triggering IME
        # this is to avoid conflicts with other apps/games
        "Hotkey/TriggerKeys"."0" = "Control+Alt+space";
      };

      # basic configuration for switching between normal mode and mozc
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "mozc";
        };

        "Groups/0/Items/0" = {
          Name = "keyboard-us";
          Layout = "us";
        };

        "Groups/0/Items/1" = {
          Name = "mozc";
          Layout = "us";
        };

        GroupOrder."0" = "Default";
      };

      settings.addons.classicui.globalSection.Theme = "plasma";
    };
  };
  fonts.enableDefaultPackages = true;

  # enable waydroid, a container-based solution to android emulation
  # virtualisation.waydroid.enable = true;

  # use virt-manager for any* guest
  # programs.virt-manager.enable = true;
  # virtualisation.libvirtd.enable = true;
  # users.users.nixosuser.extraGroups = [ "libvirtd" ];

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

  # Open ports in the firewall (for graphical apps)
  # networking.firewall.allowedTCPPorts = [ ];
  # networking.firewall.allowedUDPPorts = [ ];

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
