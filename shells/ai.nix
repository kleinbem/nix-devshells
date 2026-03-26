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
    pkgs.aider-chat
    pkgs.oterm
    pkgs.llm
    pkgs.fabric-ai
    pkgs.nix-tree
    pkgs.nix-du
    pkgs.dust
    pkgs.glances
  ];

  env = {
    OPENAI_API_BASE = "http://localhost:4000/v1";
    OPENAI_API_KEY = "sk-placeholder";
  };

  enterShell = ''
    echo "🤖 AI DevShell Loaded (LiteLLM @ localhost:4000)"
    echo "🛡️ Agent Sanctuary active: Use 'jail-exec <command>' to sandbox agents."
  '';
}
