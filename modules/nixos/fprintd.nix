{ config, lib, ... }:

{
  options.features.fprintd.enable = lib.mkEnableOption "Fingerprint daemon and authentication support";

  config = lib.mkIf config.features.fprintd.enable {
    services.fprintd.enable = true;

    security.polkit.enable = true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "net.reactivated.fprint.device.enroll" ||
             action.id == "net.reactivated.fprint.device.verify") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

    security.pam.services = {
      login.fprintAuth = true;
      sudo.fprintAuth = true;
      su.fprintAuth = true;
      greetd.fprintAuth = true;
    };
  };
}
