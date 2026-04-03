{ config, lib, pkgs, inputs, ... }:

{
  options.features.users.sammy.enable = lib.mkEnableOption "Sammy user configuration and Home Manager setup";

  config = lib.mkIf config.features.users.sammy.enable {
    users.users.sammy = {
      isNormalUser = true;
      description = "Sammy";
      shell = pkgs.fish;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [
        zed-editor
        osu-lazer-bin
        gh
        bluetui
        nixd
        nil
        gemini-cli
        inputs.helium.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];
    };

    programs.fish.enable = true;

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      useGlobalPkgs = true;
      useUserPackages = true;
      users.sammy = import ../home;
    };

    environment.systemPackages = [
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
