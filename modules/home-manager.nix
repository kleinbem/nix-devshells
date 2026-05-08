{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.devshell-launchers;
in
{
  options.modules.devshell-launchers = {
    enable = mkEnableOption "desktop launchers for devshells";
    flakePath = mkOption {
      type = types.str;
      default = "/home/martin/Develop/github.com/kleinbem/nix";
      description = "Path to the root flake containing the devshells";
    };
  };

  config = mkIf cfg.enable {
    xdg.desktopEntries = {
      # --- Apps Shell ---
      qbittorrent-devshell = {
        name = "qBittorrent (DevShell)";
        genericName = "BitTorrent Client";
        exec = "\"nix develop ${cfg.flakePath}#apps -c qbittorrent %U\"";
        terminal = false;
        categories = [
          "Network"
          "FileTransfer"
          "P2P"
        ];
        icon = "qbittorrent";
      };
      slack-devshell = {
        name = "Slack (DevShell)";
        genericName = "Messaging";
        exec = "\"nix develop ${cfg.flakePath}#apps -c slack %U\"";
        terminal = false;
        categories = [
          "Network"
          "InstantMessaging"
        ];
        icon = "slack";
      };
      dbeaver-devshell = {
        name = "DBeaver (DevShell)";
        genericName = "Universal Database Tool";
        exec = "\"nix develop ${cfg.flakePath}#apps -c dbeaver\"";
        terminal = false;
        categories = [
          "Development"
          "Database"
        ];
        icon = "dbeaver";
      };
      bruno-devshell = {
        name = "Bruno (DevShell)";
        genericName = "API Client";
        exec = "\"nix develop ${cfg.flakePath}#apps -c bruno %U\"";
        terminal = false;
        categories = [ "Development" ];
        icon = "bruno";
      };
      github-desktop-devshell = {
        name = "GitHub Desktop (DevShell)";
        genericName = "Git GUI";
        exec = "\"nix develop ${cfg.flakePath}#apps -c github-desktop %U\"";
        terminal = false;
        categories = [
          "Development"
          "RevisionControl"
        ];
        icon = "github-desktop";
      };
      rustdesk-devshell = {
        name = "RustDesk (DevShell)";
        genericName = "Remote Desktop";
        exec = "\"nix develop ${cfg.flakePath}#apps -c rustdesk\"";
        terminal = false;
        categories = [
          "Network"
          "RemoteAccess"
        ];
        icon = "rustdesk";
      };

      # --- Pentest Shell ---
      wireshark-devshell = {
        name = "Wireshark (DevShell)";
        genericName = "Network Analyzer";
        exec = "\"nix develop ${cfg.flakePath}#pentest -c wireshark %f\"";
        terminal = false;
        categories = [
          "System"
          "Network"
        ];
        icon = "wireshark";
      };
      burpsuite-devshell = {
        name = "Burp Suite (DevShell)";
        genericName = "Web Security Testing";
        exec = "\"nix develop ${cfg.flakePath}#pentest -c burpsuite\"";
        terminal = false;
        categories = [
          "Development"
          "Security"
        ];
        icon = "burpsuite";
      };
      zenmap-devshell = {
        name = "Zenmap (DevShell)";
        genericName = "Network Mapper";
        exec = "\"nix develop ${cfg.flakePath}#pentest -c zenmap\"";
        terminal = false;
        categories = [
          "System"
          "Network"
          "Security"
        ];
        icon = "zenmap";
      };
      chromium-pentest = {
        name = "Chromium (Pentest)";
        genericName = "Web Browser";
        exec = "\"nix develop ${cfg.flakePath}#pentest -c chromium %U\"";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        icon = "chromium";
      };
      zap-devshell = {
        name = "OWASP ZAP (DevShell)";
        genericName = "Web App Scanner";
        exec = "\"nix develop ${cfg.flakePath}#pentest -c zaproxy\"";
        terminal = false;
        categories = [
          "Development"
          "Security"
        ];
        icon = "zaproxy";
      };

      # --- AI Dev Shell ---
      lmstudio-devshell = {
        name = "LM Studio (DevShell)";
        genericName = "Local AI Models";
        exec = "\"nix develop ${cfg.flakePath}#ai-dev -c lmstudio %U\"";
        terminal = false;
        categories = [ "Development" ];
        icon = "lmstudio";
      };

      # --- Media Shell ---
      obs-studio-devshell = {
        name = "OBS Studio (DevShell)";
        genericName = "Streaming and Recording";
        exec = "\"nix develop ${cfg.flakePath}#media -c obs\"";
        terminal = false;
        categories = [
          "AudioVideo"
          "Recorder"
        ];
        icon = "obs";
      };
    };
  };
}
