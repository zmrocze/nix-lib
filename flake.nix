{
  description = "Simple flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    # flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    let
      # We leave it to just linux to be able to run `nix flake check` on linux, 
      # see bug https://github.com/NixOS/nix/issues/4265
      # systems = [ "x86_64-linux" ];
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = nixpkgs.lib.genAttrs systems;
      mkNixpkgsFor = system: import nixpkgs {
        # overlays = nixpkgs.lib.attrValues self.overlays;
        inherit system;
      };
      allNixpkgs = perSystem mkNixpkgsFor;

      nixpkgsFor = system: allNixpkgs.${system};
    in

    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./pre-commit.nix
      ];
      inherit systems;
      perSystem = { system, config, pkgs, ... }:
        # let 
        #   pkgs = nixpkgsFor system;
        # in
        {

          devShells = {
            default = config.pre-commit.devShell;
          };
          # packages;
          # apps;
        };
      flake = {
        lib = import ./lib nixpkgs.lib;
        overlays = {
          default = import ./overlays inputs;
        };
        nixosModules = {
          default = import ./nixos-modules inputs;
        };
      };
    };
}
