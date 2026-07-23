{ inputs, ... }:

{
  flake.modules.nixos.integrations = {
    imports = [
      inputs.stylix.nixosModules.stylix
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.sopsnix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      sharedModules = [ inputs.sopsnix.homeManagerModules.sops ];
    };
  };
}
