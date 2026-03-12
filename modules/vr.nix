{ pkgs, ... }:
{
  services.monado = {
    enable = true;
    defaultRuntime = false;
  };
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
  };
  environment.systemPackages = with pkgs; [
    xrizer
    wivrn
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
