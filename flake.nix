{
  description = "Simple flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # my-lib.url = "git+file:/home/zmrocze/code/my-lib/nix-lib?branch=main";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, my-lib, lib, ... }:
    let
      # We leave it to just linux to be able to run `nix flake check` on linux, 
      # see bug https://github.com/NixOS/nix/issues/4265
      # systems = [ "x86_64-linux" ];
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    in

    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (import ./pre-commit.nix)
      ];
      inherit systems;
      perSystem = { system, config, pkgs, ... }:
        let 
          # pkgs = import nixpkgs {
          #   inherit system;
          # };
        in
        {

          devShells = {
            default =
            #  pkgs.mergeShells config.devShells.dev-pre-commit
             (
              pkgs.mkShell {
                packages = [ 
                  # pkgs.protobuf
                  ];
                # inputsFrom
                # shellHook
              }
            );
          };

          # packages;
          # apps;
        };
      # flake = {

      # };
    };
}
