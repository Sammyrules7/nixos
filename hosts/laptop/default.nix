{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];
  programs.gamescope = {
    enable = true;
    capSysNice = true; # Helps with smooth frame timing
  };
  features.fprintd.enable = true;
  features.ollama = {
    enable = true;
    acceleration = "rocm";
    onlyOnAC = true;
  };
  features.openclaw-node.enable = true;
  features.power.enable = true;
  features.upgrade = {
    cpuThreads = 2;
    memoryHigh = "3G";
    memoryMax = "4G";
  };
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  networking.hostName = "Sammy_Laptop";
  services.tailscale.extraSetFlags = [ "--hostname=sammylaptop" ];
  boot.kernel.sysctl."vm.swappiness" = 180;
  boot.kernelParams = [
    "amd_iommu=off"
    "amdgpu.fastboot=1"
    "swiotlb=262144"
  ];

  users.users.${config.workstation.user.name}.extraGroups = [
    "video"
    "iio"
  ];

  boot.initrd.kernelModules = [
    "tpm_crb"
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      libva
      libva-utils
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
    ];
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # A lid event arrives immediately, including short closes that never suspend.
  # Keep IIO polling away from the sleeping HID sensor, then reclaim it on open.
  systemd.services.framework-als-lid = {
    description = "Framework ambient light sensor lid recovery";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-logind.service" ];
    path = [
      pkgs.systemd
      pkgs.util-linux
      pkgs.coreutils
    ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${./als-lid.py} ${config.workstation.user.name} ${
        toString config.users.users.${config.workstation.user.name}.uid
      }";
      Restart = "on-failure";
      RestartSec = "3s";
    };
  };
  systemd.services.framework-als-resume = {
    description = "Recover Framework ALS after suspend with the lid open";
    wantedBy = [ "suspend.target" ];
    after = [ "systemd-suspend.service" ];
    path = [
      pkgs.systemd
      pkgs.util-linux
      pkgs.coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3}/bin/python3 ${./als-lid.py} ${config.workstation.user.name} ${
        toString config.users.users.${config.workstation.user.name}.uid
      } --recover";
    };
  };

  boot.initrd.luks.devices."luks-9a6748f1-b660-4f2c-b9fe-40b0dd70c0d7" = {
    device = "/dev/disk/by-uuid/9a6748f1-b660-4f2c-b9fe-40b0dd70c0d7";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  home-manager.users.${config.workstation.user.name} = {
    imports = [
      ./displays.nix
    ];
    features.moonlight.settings = {
      width = 2256;
      height = 1504;
      bitrate = 40000;
    };
    features.btop.package = pkgs.btop.override { rocmSupport = true; };
    features.voxtype = {
      enable = true;
      model = "base.en";
    };
    features.theming = {
      scaling = 1.0;
    };
    features.wluma.enable = true;
    features.wluma.package = pkgs.wluma.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        # Two readings per second are responsive without hammering the HID hub.
        substituteInPlace src/als/controller.rs \
          --replace-fail 'WAITING_SLEEP_MS: u64 = 100' 'WAITING_SLEEP_MS: u64 = 500'
        # Seek before reading, so a failed sysfs read cannot leave a stale offset.
        substituteInPlace src/device_file.rs \
          --replace-fail 'file.read_to_string(&mut content).await?;' \
            'file.seek(SeekFrom::Start(0)).await?; file.read_to_string(&mut content).await?;'
      '';
    });
    wayland.windowManager.hyprland.settings.config.input.sensitivity = 0.3;
  };
}
