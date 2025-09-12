{
  inputs = {
    # This is pointing to an unstable release.
    # If you prefer a stable release instead, you can this to the latest number shown here: https://nixos.org/download
    # i.e. nixos-25.05
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # optional input: "NixOS profiles to optimize settings for different hardware"
    # nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  outputs = { nixpkgs, ... }: {
    # NOTE: 'nixos' is the default hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./graphical.nix

        # nixos-hardware.nixosModules.YOUR_DEVICE
        # add your device if it is listed here: https://github.com/NixOS/nixos-hardware
      ];
    };
  };
}
