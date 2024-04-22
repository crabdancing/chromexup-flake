{ overlay }: { config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.chromexup;
  iniFormat = pkgs.formats.ini { };

in {
  options.programs.chromexup = {
    enable = mkEnableOption "chromexup";

    branding = mkOption {
      type = types.enum ["inox" "iridium" "chromium"];
      default = "chromium";
      description = "Name of the browser user data directory.";
    };

    parallelDownloads = mkOption {
      type = types.int;
      default = 4;
      description = "Parallel download threads.";
    };

    removeOrphans = mkOption {
      type = types.bool;
      default = false;
      description = "Remove extensions not defined in the extension section.";
    };

    extensions = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "List of browser extensions to manage.";
      example = {
        HTTPSEverywhere = "gcbommkclmclpchllfjekcdonpmejbdp";
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      overlay
    ];
    hm.programs = [
      pkgs.chromexup
    ];
    hm.xdg.configFile.".config/chromexup/config.ini".text = iniFormat.generate "config.ini" {
      main = {
        branding = cfg.branding;
        parallel_downloads = toString cfg.parallelDownloads;
        remove_orphans = if cfg.removeOrphans then "True" else "False";
      };
      extensions = cfg.extensions;
    };
  };
}

