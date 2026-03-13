{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
in {
  home.packages = with pkgs;
    [
      bear
      bpftrace
      cppcheck
      cmake-language-server
      meson
      radare2
    ]
    ++ lib.optionals isLinux [
      gdb
      lldb
      ltrace
      perf
      strace
      valgrind
    ];
}
