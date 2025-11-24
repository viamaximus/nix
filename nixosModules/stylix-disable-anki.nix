{ inputs, ... }:

{
  disabledModules = [
    "${inputs.stylix}/modules/anki/hm.nix"
  ];
}

