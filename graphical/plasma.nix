{
  pkgs,
  ...
}:

{
  services = {
    # my personal favorite Desktop Enviroment
    desktopManager.plasma6.enable = true;

    # the standard KDE display manager (graphical login prompt)
    displayManager.sddm.enable = true;
  };
  # if you're not using a display manager, you can automatically start plasma on the first TTY upon login
  # environment.interactiveShellInit = /* sh */ ''test $(tty) = /dev/tty1 && startplasma-wayland'';

  # remove plasma6 packages you don't want
  # from optionalPackages defined in nixpkgs/nixos/modules/services/desktop-managers/plasma6.nix
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-workspace-wallpapers
    kwin-x11
    elisa
    krdp
  ];

  # use kdeconnect (opens ports)
  programs.kdeconnect.enable = true;

}
