{
  description = "A flake for building chromexup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chromexup = {
      url = "github:xsmile/chromexup";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, chromexup, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = pkgs.lib;
      in {
        packages.chromexup = pkgs.stdenv.mkDerivation {
          pname = "chromexup";
          version = "unstable";
          src = chromexup;
          buildInputs = with pkgs; [ makeWrapper ];

          installPhase = ''
            mkdir -p $out/bin
            cp -r $src/* $out
            wrapProgram $out/chromexup \
              --prefix PATH : ${lib.makeBinPath [ pkgs.bash ]}
          '';
        };

        defaultPackage = self.packages.${system}.chromexup;
        apps.chromexup = flake-utils.lib.mkApp {
          drv = self.packages.${system}.chromexup;
        };
      }
    );
}

