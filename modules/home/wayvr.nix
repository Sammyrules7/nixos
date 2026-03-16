{ ... }:

{
  # WayVR configuration for VRChat OSC bindings
  # This maps OpenXR controller inputs to VRChat OSC messages
  xdg.configFile."wayvr/wayvr.json5".text = ''
    {
      // VRChat typically listens on port 9000
      osc_destination: "127.0.0.1:9000",

      mappings: [
        {
          // Personal Mirror Toggle on Left Thumbstick Click
          path: "/user/hand/left/input/thumbstick/click",
          osc_address: "/input/PersonalMirrorToggle",
          type: "boolean_to_int_pulse", // Sends 1 then 0 on press
        },
        {
          // Earmuff Mode Toggle on Right Thumbstick Click
          path: "/user/hand/right/input/thumbstick/click",
          osc_address: "/input/EarmuffToggle",
          type: "boolean_to_int_pulse",
        }
      ]
    }
  '';
}
