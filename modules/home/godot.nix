{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    godot
    godot-export-templates-bin
  ];

  home.file.".local/share/godot/export_templates".source =
    "${pkgs.godot_4-export-templates-bin}/share/godot/export_templates";

  home.sessionVariables = {
    GODOT_JAVA_SDK_PATH = "${pkgs.jdk17}";
    ANDROID_HOME = "${config.home.profileDirectory}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${config.home.profileDirectory}/libexec/android-sdk";
  };

  programs.zed-editor = {
    enable = true;
    extensions = [ "gdscript" ];
    userSettings = {
      lsp.gdscript = {
        initialization_options = {
          editor_host = "127.0.0.1";
          editor_port = 6005;
        };
      };
    };
  };
}
