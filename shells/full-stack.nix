_: {
  services.postgres.enable = true;
  services.redis.enable = true;

  # Example scripts to run things
  scripts.run-all.exec = ''
    echo "Starting services..."
    devenv up
  '';

  enterShell = ''
    echo "🚀 Full Stack DevShell Loaded"
  '';
}
