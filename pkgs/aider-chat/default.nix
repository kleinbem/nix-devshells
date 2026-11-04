# Bridge for NixOS/nixpkgs#569679: litellm >= 1.101 exports
# VectorStoreSearchError, which aider doesn't list and so raises on every send.
# Applies the upstream patch only while the pinned nixpkgs lacks it.
# nix-presets' containers/persona-runtime.nix carries the same bridge.
{ lib, aider-chat }:

if
  lib.any (p: lib.hasSuffix "add-vector-store-search-error.patch" (toString p)) (
    aider-chat.patches or [ ]
  )
then
  aider-chat
else
  aider-chat.overridePythonAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./vector-store-search-error.patch ];
  })
