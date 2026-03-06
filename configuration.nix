{ config, pkgs, inputs, ... }:

{
  imports = [
    ./Computers/Desktop/hardware-configuration.nix

  ];

  # --- Nix & Flake Settings ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org/"
      "https://zen-browser.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # --- Boot & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Networking ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- Localization ---
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  # --- Desktop Environment (♥️Hyprland♥️) ---
  programs.hyprland.enable = true;

  # --- Login Manager ---
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Use the Wayland version of SDDM
  };

  # --- Hardware Services ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- User Account ---
  users.users.sammy = {
    isNormalUser = true;
    description = "Sammy";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      zed-editor
      osu-lazer-bin
      gh
    ];
  };

  # --- Home Manager Configuration ---
  # This section handles dotfiles and user-specific logic via Flakes
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sammy = { pkgs, ... }: {
      home.stateVersion = "25.11";
      # You can add user-specific dotfiles here later
      programs.home-manager.enable = true;

      wayland.windowManager.hyprland.enable = true;
      imports = [
        ./Configs/Hypr/Hyprland/Hyprland.nix
        ./Configs/Hypr/Hyprland/Binds.nix
        ./Computers/Desktop/Displays.nix
        ./Configs/Hypr/Hyprland/Permissions.nix
        ./Configs/Hypr/Hyprland/Pretty.nix
        ./Configs/Hypr/Hyprland/Windowrules.nix
        ./Configs/Hypr/Hyprland/Input.nix
        ./Configs/Hypr/Hyprland/Autostart.nix
        ./Configs/Hypr/Hyprland/HyprPanel.nix
        ./Configs/Ghostty.nix
        ./Configs/Btop.nix
      ];

      programs.hyprpanel.enable = true;
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.roboto-mono
      ];

      programs.vesktop.enable = true;
      programs.vesktop = {
        settings = {
            "discordBranch" = "stable";
            "minimizeToTray" = true;
            "arRPC" = true;
            "splashColor" = "rgb(220, 220, 223)";
            "splashBackground" = "rgb(0, 0, 0)";
            "hardwareVideoAcceleration" = false;
            "disableSmoothScroll" = false;
          };
        vencord = {

        };
      };

      #Dark mode
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
      };
      qt = {
        enable = true;
        platformTheme.name = "gtk";
        style.name = "adwaita-dark";
      };
      home.sessionVariables = {
        GTK_THEME = "Adwaita-dark";
        QT_QPA_PLATFORMTHEME = "gtk2";

        # Wayland
        NIXOS_OZONE_WL = "1";
        SDL_VIDEODRIVER = "wayland";
      };

    };
  };

  # --- System-wide Packages ---
  environment.systemPackages = with pkgs; [
    git
    # Zen Browser from your Flake input
    inputs.zen-browser.packages."${pkgs.system}".default
  ];

  # --- System Programs ---
  programs.firefox.enable = true;

  # --- State Version ---
  system.stateVersion = "25.11";
}
