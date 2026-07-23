{ ... }:

{
  config = {
    programs.ghostty = {
      enable = true;
      systemd.enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        window-decoration = false;
        background-opacity = 0;
        shell-integration = "fish";
      };
    };
  };
}
