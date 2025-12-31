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

  # use virt-manager, a qemu GUI
  # programs.virt-manager.enable = true;
  # virtualisation.libvirtd.enable = true;
  # users.users.nixosuser.extraGroups = [ "libvirtd" ];
}
