# flake part module for defining pkgs
{ config, lib, self, ... }: {
  options = {
    pkgsConfig = with lib; {
      systems = mkOption {
        type = with types; listOf string;
        default = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        description = ''
          The systems to build pkgs for.
        '';
      };
      overlays = mkOption {
        description = "List of overlays.";
        merge = lists.concatMap trivial.id;
        default = [ ];
      };
      extraConfig = mkOption {
        description = "Extra arguments passed to `import nixpkgs`. Merged with overlays and systems.";
        default = { };
        type = with types; attrsOf inferred;
      };
      config = mkOption {
        description = "Arguments passed to `import nixpkgs`.";
        default = { inherit (config.pkgsConfig) systems overlays; } // config.pkgsConfig.extraConfig;
        type = with types; attrsOf inferred;
      };
      nixpkgs = mkOption {
        description = "Nixpkgs flake input.";
        type = with types; any;
        default = self.inputs.nixpkgs;
      };
      _allNixpkgs = mkOption {
        default = perSystem (system: import config.pkgsConfig.nixpkgs config.pkgsConfig.config);
        internal = true;
      };
    };
    pkgsFor = mkOption {
      description = "Function to generate pkgs set. Use the default value. Memorizes.";
      default = system: config.pkgsConfig._allNixpkgs.${system};
    };
  };
}
