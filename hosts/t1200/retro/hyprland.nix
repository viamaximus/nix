# Hyprland on the t1200: flat and borderless, left/right splits for the
# 1800x720 usable area, a lone window fills the screen, and every action has a
# described keybind (the descriptions feed `t1200-guide`, Super+/).
{
  config,
  lib,
  pkgs,
  ...
}: let
  hl = import ../../../homeManagerModules/hypr/lua.nix {inherit lib;};
  inherit (hl) exec focus move swap;
  toLua = lib.generators.toLua {};
  ipc = "noctalia msg";
  crt = title: cmd: exec "retro-term -T ${title} -e ${cmd}";

  # Keeps the pointer out of the bezel-hidden strips (reserved area, bezel.nix).
  cursorClamp = pkgs.callPackage ./cursor-clamp {};

  # { keys, dsp, desc, opts? } -- every key listed here is unbound first, so
  # these replace the shared binds rather than stacking on top of them.
  binds =
    [
      # ── apps ──
      (k "SUPER + Return" (exec "retro-term") "terminal (cool-retro-term + tmux)")
      (k "SUPER + SHIFT + Return" (exec "kitty") "fallback terminal (kitty: images, truecolor)")
      (k "SUPER + B" (exec "helium") "browser (Helium)")
      (k "SUPER + E" (crt "yazi" "yazi") "files (yazi)")
      (k "SUPER + D" (exec "vesktop") "discord (Vesktop)")
      (k "SUPER + SHIFT + D" (crt "discordo" "discordo") "discord in terminal (discordo)")
      (k "SUPER + S" (crt "spotify" "spotify_player") "music (spotify-player)")
      (k "SUPER + CTRL + A" (crt "mixer" "wiremix") "audio mixer (wiremix)")
      (k "SUPER + N" (crt "wifi" "impala") "wi-fi (impala)")
      (k "SUPER + SHIFT + Escape" (crt "btop" "btop") "system monitor (btop)")
      (k "SUPER + slash" (exec "t1200-guide --window") "this keybind / program guide")
      (k "SUPER + F1" (exec "t1200-guide --window") "this keybind / program guide")

      # ── shell (noctalia) ──
      (k "SUPER + space" (exec "${ipc} panel-toggle launcher") "app launcher")
      (k "SUPER + grave" (exec "${ipc} bar-toggle") "show / hide the bar")
      (k "SUPER + V" (exec "${ipc} panel-toggle clipboard") "clipboard history")
      (k "SUPER + C" (exec "${ipc} panel-toggle control-center") "control center")
      (k "SUPER + A" (exec "${ipc} panel-open control-center audio") "audio panel")
      (k "SUPER + X" (exec "${ipc} panel-toggle session") "session menu (logout / reboot / off)")
      (k "SUPER + SHIFT + L" (exec "${ipc} session lock") "lock screen")
      (k "SUPER + SHIFT + N" (exec "${ipc} nightlight-toggle") "night light")
      (k "SUPER + SHIFT + S" (exec "${ipc} screenshot-region") "screenshot region")
      (k "SUPER + M" (exec "wl-kbptr") "keyboard pointer: type a hint to click there")

      # ── windows ──
      (k "SUPER + Q" hl.close "close window")
      (k "SUPER + F" "hl.dsp.window.fullscreen_state({ internal = 1, client = 2, action = \"toggle\" })" "fullscreen (inside the bezel)")
      (k "SUPER + SHIFT + F" hl.toggleFloat "toggle floating")
      (k "SUPER + T" "hl.dsp.layout(\"togglesplit\")" "flip split left/right <-> top/bottom")
      (k "SUPER + SHIFT + T" "hl.dsp.layout(\"swapsplit\")" "swap the two sides of a split")
      (k "SUPER + Tab" (focus {last = true;}) "focus previous window")
      (k "SUPER + h" (focus {direction = "left";}) "focus left")
      (k "SUPER + j" (focus {direction = "down";}) "focus down")
      (k "SUPER + k" (focus {direction = "up";}) "focus up")
      (k "SUPER + l" (focus {direction = "right";}) "focus right")
      (k "SUPER + CTRL + h" (swap {direction = "left";}) "swap window left")
      (k "SUPER + CTRL + j" (swap {direction = "down";}) "swap window down")
      (k "SUPER + CTRL + k" (swap {direction = "up";}) "swap window up")
      (k "SUPER + CTRL + l" (swap {direction = "right";}) "swap window right")
      (r "SUPER + ALT + h" (resize (-60) 0) "resize: narrower")
      (r "SUPER + ALT + l" (resize 60 0) "resize: wider")
      (r "SUPER + ALT + k" (resize 0 (-40)) "resize: shorter")
      (r "SUPER + ALT + j" (resize 0 40) "resize: taller")

      # ── workspaces ──
      (k "SUPER + bracketleft" (focus {workspace = "r-1";}) "previous workspace")
      (k "SUPER + bracketright" (focus {workspace = "r+1";}) "next workspace")
      (k "SUPER + SHIFT + bracketleft" (move {workspace = "r-1";}) "move window to previous workspace")
      (k "SUPER + SHIFT + bracketright" (move {workspace = "r+1";}) "move window to next workspace")
      (k "SUPER + Z" "hl.dsp.workspace.toggle_special(\"scratch\")" "scratchpad: show / hide")
      (k "SUPER + SHIFT + Z" (move {workspace = "special:scratch";}) "scratchpad: send window there")

      # ── keys freed up on the QMK keyboard (see ~/qmk_firmware/keyboards/toshiba_t1200) ──
      # xkb names F13/F14 XF86Tools/XF86Launch5, so bind those keysyms
      (k "XF86Tools" (exec "t1200-guide --window") "NumLk key (F13): guide")
      (k "XF86Launch5" (exec "wl-kbptr") "ScrLk key (F14): keyboard pointer hint-click")
      (k "Print" (exec "${ipc} screenshot-region") "PrtSc key: screenshot region")

      # ── lid switch (keyboard firmware taps F24 on close, F23 on open) ──
      (k "F24" "hl.dsp.dpms({ action = \"off\" })" "lid closed: screen off")
      (k "XF86TouchpadOff" "hl.dsp.dpms({ action = \"on\" })" "lid opened: screen on (F23)")
    ]
    ++ lib.concatMap (i: [
      (k "SUPER + ${toString i}" (focus {workspace = i;}) "workspace ${toString i}")
      (k "SUPER + SHIFT + ${toString i}" (move {workspace = i;}) "move window to workspace ${toString i}")
    ]) (lib.range 1 9);

  k = keys: dsp: desc: {inherit keys dsp desc; opts = {};};
  r = keys: dsp: desc: {
    inherit keys dsp desc;
    opts = {repeating = true;};
  };
  resize = x: y: "hl.dsp.window.resize(${toLua {inherit x y; relative = true;}})";

  renderBind = b: "hl.bind(${toLua b.keys}, ${b.dsp}, ${toLua (b.opts // {description = b.desc;})})";
  unbindKeys = lib.unique (map (b: b.keys) binds);
in {
  wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        gaps_in = lib.mkForce 2;
        gaps_out = lib.mkForce 0;
        border_size = lib.mkForce 0;
      };
      decoration = {
        rounding = lib.mkForce 0;
        blur.enabled = lib.mkForce false;
        active_opacity = lib.mkForce 1.0;
        inactive_opacity = lib.mkForce 1.0;
        shadow.enabled = false;
        # whole-display mild CRT filter (scanlines, glow, vignette); "" disables
        screen_shader = "${./crt.frag}";
      };
      animations.enabled = lib.mkForce false;

      # New windows split the focused one along its longer side, always to the
      # right/bottom. On 1800x720 that's: 1 = full, 2-3 = side by side, the 4th
      # stacks top/bottom (a 450px column is taller than it is wide).
      dwindle = {
        smart_split = lib.mkForce false;
        force_split = 2;
        split_width_multiplier = 1.0;
      };

      cursor = {
        inactive_timeout = 3;
        hide_on_key_press = true;
      };
    };

    # A lone tiled window gets no gaps, so it looks fullscreen until a second
    # window splits it.
    workspace_rule = [
      {
        workspace = "w[tv1]";
        gaps_in = 0;
        gaps_out = 0;
      }
    ];

    window_rule = [
      {
        name = "t1200-guide";
        match.title = "^t1200-guide$";
        float = true;
        size = "1600 660";
        center = true;
      }
    ];

    env = [(hl.env "TERMINAL" "retro-term")];
  };

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    hl.plugin.load("${cursorClamp}/lib/libcursor-clamp.so")

    -- ── t1200 keymap (see hosts/t1200/retro/hyprland.nix) ──
    ${lib.concatMapStrings (key: "pcall(hl.unbind, ${toLua key})\n") unbindKeys}
    ${lib.concatMapStrings (b: renderBind b + "\n") binds}
  '';

  home.packages = [pkgs.wl-kbptr];
}
