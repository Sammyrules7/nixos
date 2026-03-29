{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # 1. Add Home Manager input
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    helium.url = "github:schembriaiden/helium-browser-nix-flake";

    stylix.url = "github:nix-community/stylix";

    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    dashboard-icons = {
      url = "github:homarr-labs/dashboard-icons";
      flake = false;
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    {
      nixosConfigurations.Desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
          ./hosts/desktop
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.Laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
          ./hosts/laptop
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
