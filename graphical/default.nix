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
    # ./nvidia.nix
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
}
