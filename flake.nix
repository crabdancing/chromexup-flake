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
        chromexup = pkgs.callPackage ./pkg.nix;
      in
      {
        # Provide Nix packages and apps using the package built above
        packages.chromexup = chromexup;
        apps.chromexup = pkgs.lib.mkApp {
          inherit (pkgs.chromexup) drv;
          program = "${pkgs.chromexup}/bin/chromexup";
        };
        packages.default = chromexup;

      })) // (let

        overlay = import ./overlay.nix { inherit chromexup-src; };
        homeModule = { config, ... }: {
          imports = [
            (import ./module.nix { inherit overlay; })
          ];
        };
        module = { ... }: {
          overlays = [ overlay ];
        };
      in {
        overlays = {
          default = overlay;
          chromexup = overlay;
        };
        nixosModules = {
          default = module;
          chromexup = module;
        };
      
        homeManagerModules = {
          default = homeModule;
          chromexup = homeModule;
        };
      });
}


