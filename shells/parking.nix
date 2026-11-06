{
  lib,
  ...
}:
{
  imports = [ ./common.nix ];

  env.DEV_SHELL_NAME = lib.mkDefault "parking";
  env.STARSHIP_SHELL_SYMBOL = lib.mkDefault "🅿️ ";

  # --- Parking / Staging Sandbox ---
  # Quarantine for packages under repair or waiting on upstream, so they can't
  # break the other shells. Add each with its issue/PR link, test it via
  # `nix develop .#parking`, and move it back once it works.
  packages = [ ];
}
