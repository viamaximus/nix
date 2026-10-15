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

  unityEditor = pkgs.writeShellScriptBin "vrcdev-unity" ''
    editor="$HOME/Unity/Hub/Editor/${cfg.unityVersion}/Editor/Unity"
    if [ ! -x "$editor" ]; then
      echo "Unity ${cfg.unityVersion} is not installed. Run vrcdev-install-unity first." >&2
      exit 1
    fi
    exec ${unityhub.fhsEnv}/bin/unityhub-fhs-env "$editor" ${lib.optionalString cfg.forceVulkan "-force-vulkan"} "$@"
  '';

  addRepos = pkgs.writeShellScriptBin "vrcdev-add-repos" ''
    for repo in ${escapeShellArgs cfg.vpmRepos}; do
      ${pkgs.vrc-get}/bin/vrc-get repo add "$repo" || true
    done
    ${pkgs.vrc-get}/bin/vrc-get repo list
  '';
in {
  options.features.vrcdev = {
    enable = mkEnableOption "VRChat avatar development (Unity + Creator Companion + SDK tooling)";

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

    forceVulkan = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Launch the editor with -force-vulkan. The Linux editor otherwise falls
        back to GLCore, whose shader keyword limits are too low for Poiyomi and
        lilToon: materials fail with "State comes from an incompatible keyword
        space" and avatars render untextured or invisible.
      '';
    };

    quest.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install adb and expose it inside the Unity FHS environment for Quest builds.";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      [
        unityhub
        installUnity
        unityEditor
        addRepos
        pkgs.alcom
        pkgs.vrc-get
      ]
      ++ optional cfg.quest.enable pkgs.android-tools;

    home.sessionVariables.VRCDEV_UNITY_VERSION = cfg.unityVersion;
  };
}
