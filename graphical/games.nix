{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # performance overlay
    mangohud
  ];

  # Steam (games)
  programs.steam = {
    enable = true;

    # open firewall to let these steam features work
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # add GE-Proton if it might help
    extraCompatPackages = [ pkgs.proton-ge-bin ];

    # protontricks, a winetricks wrapper for proton
    # also includes protontricks-launch which allows you to launch apps in the selected steam game prefix
    # protontricks.enable = true;
  };
  environment.variables = {
    MANGOHUD = 1; # enable mangohud by default on all vulkan games
  };
}
