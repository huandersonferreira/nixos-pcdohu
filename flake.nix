{
  description = "NixOS configuration for huanderson's PC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix.url = "github:ryantm/agenix";

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, impermanence, ... }@inputs:

  let
    system = "x86_64-linux";
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  
  in {
    nixosConfigurations = {
      pcdohu = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgsUnstable; };
        modules = [
          ./hosts/pcdohu/configuration.nix

          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          impermanence.nixosModules.impermanence

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs pkgsUnstable; };
            home-manager.users.huanderson = import ./home/huanderson.nix;
          }
        ];
      };
    };
  };
}