{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };
  outputs = inputs:
    with inputs; let
      specialArgs = {inherit inputs;};
    in {
      nixosConfigurations = {
        pi = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "aarch64-linux";
          modules = [
            nixos-hardware.nixosModules.raspberry-pi-4
            ./hosts/pi
          ];
        };
      };
    };
}
