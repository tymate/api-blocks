{
  description = "API Blocks flake";

  inputs = {
    dev-shells.url = "github:pauldub/nix-dev-shells";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, dev-shells, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let inherit (dev-shells.lib) devShell;
      in { devShell = (devShell system "ruby"); });
}
