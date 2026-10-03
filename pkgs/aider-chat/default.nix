# Bridge for NixOS/nixpkgs#569679 (merged 2026-10-03): litellm >= 1.101
# exports VectorStoreSearchError, and aider's LiteLLMExceptions raises on any
# litellm *Error it doesn't list — on every send, not just in its tests
# (which is where the build fails). Same patch as upstream; it drops itself
# once the pinned nixpkgs carries it, leaving plain (cache-hit) nixpkgs
# aider. nix-presets' containers/persona-runtime.nix carries the same bridge.
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
