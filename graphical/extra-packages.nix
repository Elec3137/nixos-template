{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # video editor
    kdePackages.kdenlive

    # office suite
    libreoffice-qt-fresh

    # GUI that can do things like filter noise from microphone
    easyeffects

    # encryption tool
    kdePackages.kleopatra
    # my password manager of choice
    keepassxc
    # keepassxc requires plasma5support for "classic" (system) theme to look right(ish) on plasma
    # this is due to the fact that it is still on qt5
    kdePackages.plasma5support

    # torrenting client
    qbittorrent

    # resource monitors
    # switch these based on your gpu
    btop-rocm
    nvtopPackages.amd
  ];

  # otherwise kleopatra failes with "No Pinentry"
  programs.gnupg.agent.enable = true;

}
