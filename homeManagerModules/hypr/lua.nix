# Helpers for Hyprland's Lua config via HM's `settings` (configType = "lua").
# Each `settings.<name>` entry renders as `hl.<name>(...)`; `{ _args = [..]; }`
# expands to multiple arguments and `inline` values are emitted as raw Lua.
{lib}: let
  toLua = lib.generators.toLua {};
  inline = lib.generators.mkLuaInline;
  luaTable = attrs: toLua attrs;
in rec {
  inherit inline toLua;

  mod = "SUPER";

  bind = keys: dsp: {_args = [keys (inline dsp)];};
  bindWith = opts: keys: dsp: {_args = [keys (inline dsp) opts];};

  bindel = bindWith {
    locked = true;
    repeating = true;
  };
  bindm = bindWith {mouse = true;};

  exec = cmd: "hl.dsp.exec_cmd(${toLua cmd})";
  close = "hl.dsp.window.close()";
  fullscreen = "hl.dsp.window.fullscreen()";
  toggleFloat = "hl.dsp.window.float(${luaTable {action = "toggle";}})";
  focus = args: "hl.dsp.focus(${luaTable args})";
  move = args: "hl.dsp.window.move(${luaTable args})";
  swap = args: "hl.dsp.window.swap(${luaTable args})";
  drag = "hl.dsp.window.drag()";
  resize = "hl.dsp.window.resize()";

  env = name: value: {_args = [name value];};

  onStart = cmds: {
    _args = [
      "hyprland.start"
      (inline "function()\n${lib.concatMapStrings (c: "  hl.exec_cmd(${toLua c})\n") cmds}end")
    ];
  };
}
