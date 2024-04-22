{
  description = "A flake for building chromexup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    chromexup.url = "github:xsmile/chromexup";
    chromexup.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, chromexup }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Prepare the Python package using the setup.py in the chromexup repository
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: super: {
              chromexup = super.python3Packages.buildPythonApplication {
                pname = "chromexup";
                version = "unstable"; # Use 'unstable' as there is no version in the repo
                src = chromexup;
                propagatedBuildInputs = with super.python3Packages; [ requests ];
                # You may need to add more Python dependencies depending on the actual needs
                # You could also override 'doCheck' and other attributes as required
              };
            })
          ];
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
      });
}

