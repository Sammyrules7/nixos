{ pkgs, ... }:

{
  # --- Steam & Gaming ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    
    # Optional: ensure proton-ge is globally available
    extraPackages = with pkgs; [
      proton-ge-bin
      gamemode
    ];
  };

  programs.gamemode.enable = true;

  # --- Monado (OpenXR Runtime) ---
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };

  # --- WiVRn (Wireless VR) ---
  # Note: wivrn provides a service for streaming VR content wirelessly (Quest, etc)
  # It works in conjunction with Monado.
  services.wivrn = {
    enable = true;
    openFirewall = true;
    # Default runtime is usually Monado, but WiVRn can act as its own.
    # If using WiVRn as the primary, we'll enable its runtime.
    defaultRuntime = true; 
  };

  # --- Xrizer ---
  # Xrizer is a wrapper that helps OpenXR games find the runtime.
  # Usually used by prefixing the command: xrizer steam-app-id
  environment.systemPackages = with pkgs; [
    xrizer
    proton-ge-bin
    wivrn
  ];

  # --- Hardware/Video Optimization ---
  # Required for VR performance
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
