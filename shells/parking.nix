{
  lib,
  ...
}:
{
  imports = [ ./common.nix ];

  env.DEV_SHELL_NAME = lib.mkDefault "parking";
  env.STARSHIP_SHELL_SYMBOL = lib.mkDefault "🅿️ ";

  # --- Parking / Staging Sandbox ---
  # This shell is a quarantine station for apps or packages currently undergoing
  # active repair, custom patch testing, or awaiting upstream PR merges.
  #
  # Keeping broken WIP packages here ensures they NEVER block the main #apps,
  # #pentest, or #workspace devshells.
  #
  # Workflow:
  # 1. Place broken packages with their tracking issue / PR link below.
  # 2. Enter shell with: nix develop .#parking
  # 3. Test overrides and patches in isolation.
  # 4. Once working, promote back to production shell and clear from here.
  packages = [ ];
}
