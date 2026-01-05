{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # for clipboard sharing with waydroid
    wl-clipboard
  ];

  # enable waydroid, a container-based solution to android emulation
  virtualisation.waydroid.enable = true;
  # needed sometimes till https://github.com/NixOS/nixpkgs/pull/466473
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # use virt-manager, a qemu GUI
  # programs.virt-manager.enable = true;
  # virtualisation.libvirtd.enable = true;
  # users.users.XXX.extraGroups = [ "libvirtd" ];
}
