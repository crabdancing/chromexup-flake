# chromexup for NixOS

In the shitfuck mess that is the modern browser ecosystem, `ungoogled-chromium` is a fairly solid browser choice. It's well funded, meaning the feature set & security is fairly on point -- but it's also a fork with all Google's weird BDSM stuff removed. Awesome!

There's a problem though.

It can't interface with the Chromium web store! There are extensions to do this, but us Nix weirdos like to do things declaratively, so I'm using an ancient script called [chromexup](https://github.com/xsmile/chromexup). And amazingly, it still works fine, 6 years later without any changes!

However, it was somehow never packaged for Nix.

So this repo takes care of the following problems:
- Package the `chromexup` repo for Nix so that it can be called from CLI.
- Add a Home Manager module to configure it declaratively

# How to use

Get your system flake inputs in order:

```nix
  # inside `inputs` scope
  chromexup.url = "github:crabdancing/chromexup-flake";
```

And hook it up to your `home-manager` instance:

```nix
# inside a module's `config` scope
home-manager.sharedModules = [
    inputs.chromexup.homeManagerModules.default
];
```

At which point, you can configure it inside home-manager for any user:

```nix
# inside a module's `config` scope
home-manager.red.programs.chromexup = {
  enable = true;
  extensions = {
    UBlockOrigin = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
    Bitwarden = "nngceckbapebfimnlniiiahkandclblb";
    CurlWget = "dgcfkhmmpcmkikfmonjcalnjcmjcjjdn";
  };
};
```

This will also automatically enable a systemd service & timer, so it will automatically run daily!