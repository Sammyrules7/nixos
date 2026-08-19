{ lib }:

let
  toLua = lib.generators.toLua { };
  inline = lib.generators.mkLuaInline;
in
{
  inherit inline toLua;

  dispatcher = name: argument: inline "hl.dsp.${name}(${toLua argument})";
  dispatcher0 = name: inline "hl.dsp.${name}()";
  windowDispatcher = name: argument: inline "hl.dsp.window.${name}(${toLua argument})";
  windowDispatcher0 = name: inline "hl.dsp.window.${name}()";

  bind = keys: action: {
    _args = [
      keys
      action
    ];
  };

  bindWith = keys: action: options: {
    _args = [
      keys
      action
      options
    ];
  };
}
