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
          imports = [
            modules.homeManager.workstation
            inputs.zen-browser.homeModules.beta
          ];

          home = {
            username = cfg.name;
            homeDirectory = cfg.homeDirectory;
          };

          stylix.targets.zen-browser.enable = false;

          programs.zen-browser = {
            enable = true;

            policies.ExtensionSettings = {
              "{91aa3897-2634-4a8a-9092-279db23a7689}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/zen-internet/latest.xpi";
                installation_mode = "normal_installed";
              };

              "addon@darkreader.org" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
                installation_mode = "normal_installed";
              };
            };

            profiles.default = {
              name = "Default Profile";
              path = "337jzpxv.Default Profile";
              mods = [
                "642854b5-88b4-4c40-b256-e035532109df" # Transparent Zen
              ];
            };
          };
        };
      };
    };
}
