{
  pkgs,
  ...
}:

{
  imports = [
    ./browsers.nix
    ./plasma.nix
    # ./games.nix
    # ./extra-packages.nix
    # ./virt.nix
  ];

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

    # If you're using Full Disk Encryption, you could enable autologin in the shell
    # getty.autologinUser = "XXX";
    # getty.autologinOnce = true;
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    # media player
    mpv
  ];

  # enable default fonts (helps with emojis, etc)
  fonts.enableDefaultPackages = true;
  # for higher quality asian fonts
  # without this, chromium doesn't render asian text at all
  fonts.packages = [ pkgs.noto-fonts-cjk-sans ];

  # input method editor (ie for typing in japanese)
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
