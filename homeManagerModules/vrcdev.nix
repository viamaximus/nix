{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.vrcdev;

  unityhub = pkgs.unityhub.override {
    extraPkgs = pkgs:
      with pkgs;
        [python3]
        ++ optional cfg.quest.enable android-tools;
  };

  moduleFlags = concatMapStringsSep " " (m: "--module ${escapeShellArg m}") cfg.unityModules;

  installUnity = pkgs.writeShellScriptBin "vrcdev-install-unity" ''
    exec ${unityhub}/bin/unityhub --headless install \
      --version ${escapeShellArg cfg.unityVersion} \
      --changeset ${escapeShellArg cfg.unityChangeset} \
      ${moduleFlags} --childModules "$@"
  '';

  addRepos = pkgs.writeShellScriptBin "vrcdev-add-repos" ''
    for repo in ${escapeShellArgs cfg.vpmRepos}; do
      ${pkgs.vrc-get}/bin/vrc-get repo add "$repo" || true
    done
    ${pkgs.vrc-get}/bin/vrc-get repo list
  '';
in {
  options.features.vrcdev = {
    enable = mkEnableOption "VRChat avatar development (Unity + Creator Companion + Blender)";

    unityVersion = mkOption {
      type = types.str;
      default = "2022.3.22f1";
      description = ''
        Unity editor version the VRChat SDK targets. VRChat pins this hard —
        uploading from any other version breaks content loading, and the Unity 6
        client does not change the SDK requirement.
      '';
    };

    unityChangeset = mkOption {
      type = types.str;
      default = "887be4894c44";
      description = "Unity release changeset matching unityVersion, for the Hub install URL.";
    };

    unityModules = mkOption {
      type = types.listOf types.str;
      default = ["windows-mono" "android"];
      description = ''
        Unity Hub build-support modules. windows-mono is required even on Linux:
        VRChat PC content builds for StandaloneWindows64. android covers Quest.
      '';
    };

    vpmRepos = mkOption {
      type = types.listOf types.str;
      default = ["https://befuddledlabs.github.io/LinuxVRChatSDKPatch/index.json"];
      description = ''
        VPM listings registered by vrcdev-add-repos. The default carries
        BefuddledLabs' Linux SDK patch, which fixes SDK init, the Content
        Manager tab and Build & Test on Linux.
      '';
    };

    quest.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install adb and expose it inside the Unity FHS environment for Quest builds.";
    };

    blender.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install Blender for avatar mesh/rig work.";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      [
        unityhub
        installUnity
        addRepos
        pkgs.alcom
        pkgs.vrc-get
      ]
      ++ optional cfg.blender.enable pkgs.blender
      ++ optional cfg.quest.enable pkgs.android-tools;

    home.sessionVariables.VRCDEV_UNITY_VERSION = cfg.unityVersion;
  };
}
