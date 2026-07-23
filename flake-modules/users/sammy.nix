{
  config,
  inputs,
  ...
}:

let
  modules = config.flake.modules;
in
{
  flake.modules.nixos.user-sammy =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.workstation.user;
    in
    {
      options.workstation.user = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "sammy";
          description = "Primary workstation user name.";
        };

        homeDirectory = lib.mkOption {
          type = lib.types.str;
          default = "/home/${cfg.name}";
          description = "Primary workstation user home directory.";
        };
      };

      config = {
        users.users.${cfg.name} = {
          isNormalUser = true;
          description = "Sammy";
          uid = 1000;
          home = cfg.homeDirectory;
          shell = pkgs.fish;
          extraGroups = [
            "networkmanager"
            "wheel"
            "video"
            "input"
          ];
          packages = with pkgs; [
            zed-editor
            osu-lazer-bin
            gh
            bluetui
            nixd
            nil
            gemini-cli
            cloudflare-warp
            inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
        };

        programs.fish.enable = true;

        home-manager.users.${cfg.name} = {
          imports = [ modules.homeManager.workstation ];
          home = {
            username = cfg.name;
            homeDirectory = cfg.homeDirectory;
          };
        };

        environment.systemPackages = [
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
}
