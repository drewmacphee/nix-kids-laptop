{
  description = "Kids Laptop NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Shared configuration for all hosts  
      # The hostname will be read from /etc/hostname by configuration.nix
      mkHost = name: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.drew = import ./home-drew.nix;
            home-manager.users.emily = import ./home-emily.nix;
            home-manager.users.bella = import ./home-bella.nix;
          }
        ];
      };
    in {
      # Multiple hostname configs that all use the same modules
      # Add new hostnames here as needed
      nixosConfigurations = {
        bazztop = mkHost "bazztop";
        emily-laptop = mkHost "emily-laptop";
        bella-laptop = mkHost "bella-laptop";
        kids-desktop = mkHost "kids-desktop";
      };
    };
}
