{chromexup-src}: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.chromexup;
  iniFormat = pkgs.formats.ini {};
  package = pkgs.callPackage ./pkg.nix {inherit chromexup-src;};
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
      # should do this by default to have more nixos-like behavior
      default = true;
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
    home.packages = [
      package
    ];
    xdg.configFile."chromexup/config.ini".source = iniFormat.generate "config.ini" {
      main = {
        branding = cfg.branding;
        parallel_downloads = toString cfg.parallelDownloads;
        remove_orphans =
          if cfg.removeOrphans
          then "True"
          else "False";
      };
      extensions = cfg.extensions;
    };

    systemd.user.timers.chromexup = {
      Unit = {
        Description = "Run chromexup daily";
      };

      Timer = {
        OnActiveSec = 10;
        OnCalendar = "daily";
        Persistent = true;
      };

      Install = {
        WantedBy = ["timers.target"];
      };
    };

    systemd.user.services.chromexup = {
      Unit = {
        Description = "External extension updater for Chromium based browsers";
        After = ["network-online.target" "psd-resync.service"];
        Wants = ["network-online.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${package}/bin/chromexup";
      };
    };
  };
}
