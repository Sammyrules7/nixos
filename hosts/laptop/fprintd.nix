{ ... }:

{
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
    sudo.fprintAuth = true;
    greetd.fprintAuth = true;
    login.fprintAuth = true;
  };
}
