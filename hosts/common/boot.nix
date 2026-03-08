{ pkgs, ... }:

{
  boot.initrd.systemd.enable = true;
  boot.initrd.compressor = "zstd";

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
    editor = false;
    consoleMode = "0";
  };
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  services.scx = {
    enable = true;
    scheduler = "scx_rustland";
  };

  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "fastboot"
    "loglevel=3"
    "rd.systemd.show_status=auto"
    "nowatchdog"
    "nmi_watchdog=0"
    "amdgpu.fastboot=1"
  ];
}
