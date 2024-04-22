{
  description = "A flake for building chromexup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    chromexup-src.url = "github:xsmile/chromexup";
    chromexup-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, chromexup-src }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = import ./overlay.nix { inherit chromexup-src; };
        # Prepare the Python package using the setup.py in the chromexup repository
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        # Provide Nix packages and apps using the package built above
        packages.chromexup = pkgs.chromexup;
        apps.chromexup = pkgs.lib.mkApp {
          inherit (pkgs.chromexup) drv;
          program = "${pkgs.chromexup}/bin/chromexup";
        };
        defaultPackage = pkgs.chromexup;

      })) // (let

        overlay = import ./overlay.nix { inherit chromexup-src; };
        module = { config, ... }: {
          overlays = [ overlay ];
          imports = [
            ./module.nix
          ];
        };
      in {
      
        homeManagerModules = {
          default = module;
          chromexup = module;
        };
      });
}


