{ pkgs, ... }:
{
  name = "ai-shell";
  imports = [
    ../modules/jail.nix
  ];

  my.jail.enable = true;

  languages.python = {
    enable = true;
    uv.enable = true;
  };

  packages = [
    pkgs.ollama
    pkgs.aider-chat
    pkgs.oterm
    pkgs.llm
    pkgs.fabric-ai
    pkgs.nix-tree
    pkgs.nix-du
    pkgs.dust
    pkgs.glances
  ];

  processes.ollama.exec = "ollama serve";

  enterShell = ''
    echo "🤖 AI DevShell Loaded (Ollama Ready - 'devenv up' to start)"
    echo "🛡️ Agent Sanctuary active: Use 'jail-exec <command>' to sandbox agents."
  '';
}
