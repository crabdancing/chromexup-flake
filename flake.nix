{
  description = "A flake for building chromexup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    chromexup-src.url = "github:xsmile/chromexup";
    chromexup-src.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    chromexup-src,
  }:
    (flake-utils.lib.eachDefaultSystem (system: let
      # Prepare the Python package using the setup.py in the chromexup repository
      pkgs = import nixpkgs {
        inherit system;
      };
      chromexup = pkgs.callPackage ./pkg.nix {inherit chromexup-src;};
    in {
      # Provide Nix packages and apps using the package built above
      packages.chromexup = chromexup;
      # broken?
      # apps.chromexup = pkgs.lib.mkApp {
      #   inherit (chromexup) drv;
      #   program = "${chromexup}/bin/chromexup";
      # };
      packages.default = chromexup;
    }))
    // (let
      module = import ./module.nix {inherit chromexup-src;};
    in {
      homeManagerModules = {
        default = module;
        chromexup = module;
      };
    });
}
