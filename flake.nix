{
  description = "A flake to build the CTRL-OS Manual, based on the original sources";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    ctrl-os24-05.url = "github:cyberus-ctrl-os/nixpkgs?ref=ctrlos-24.05";
    preCommitHooksNix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.preCommitHooksNix.flakeModule
        ./checks
      ];

      perSystem =
        {
          pkgs,
          config,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
          };

          packages = {
            manualWebsite = pkgs.runCommand "manualWebsite" { } ''
              mkdir -p $out
              MANUAL_PATH=$out/ctrl-os-${inputs.ctrl-os24-05.lib.trivial.release}
              # could be looped
              mkdir -p $MANUAL_PATH
              cp -R --no-preserve=mode,ownership ${inputs.ctrl-os24-05.htmlDocs.nixpkgsManual}/share/doc/nixpkgs $MANUAL_PATH/nixpkgs
              mv $MANUAL_PATH/nixpkgs/manual.html $MANUAL_PATH/nixpkgs/index.html
              cp -R --no-preserve=mode,ownership ${inputs.ctrl-os24-05.htmlDocs.nixosManual}/share/doc/nixos $MANUAL_PATH/nixos
            '';
          };

          formatter = pkgs.nixfmt-rfc-style;

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt-rfc-style
            ]
            ++ config.pre-commit.settings.enabledPackages;
            shellHook = config.pre-commit.installationScript;
          };
        };
    };
}
