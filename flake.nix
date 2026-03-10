{
  description = "NixOS configuration for huanderson's PC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, home-manager, agenix, impermanence }:

  let system = "x86_64-linux";
  
  in {
    nixosConfigurations = {
      pcdohu = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/pcdohu/configuration.nix

          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          impermanence.nixosModules.impermanence

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.huanderson = import ./home/huanderson.nix;
          }
        ];
      };
    };
  };
}