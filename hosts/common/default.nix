{ pkgs, inputs, ... }:

{
  # --- Nix & Flake Settings ---
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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

  imports = [
    ./boot.nix
  ];
  # --- Networking ---
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false; # Don't wait for network startup

  # --- Documentation ---
  documentation.nixos.enable = false;

  # --- Localization ---
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  # --- Desktop Environment (♥️Hyprland♥️) ---
  programs.hyprland.enable = true;

  # --- Login Manager ---
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'start-hyprland' --sessions /run/current-system/sw/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  # --- Hardware Services ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
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
    ];
  };

  # --- Home Manager Configuration ---
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sammy = import ../../modules/home;
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
