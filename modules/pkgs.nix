# flake part module for defining pkgs
{ config, lib, self, ... }: {
  options = with lib; {
    pkgsConfig = {
      systems = mkOption {
        type = with types; listOf string;
        default = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        description = ''
          The systems to build pkgs for.
        '';
      };
      overlays = mkOption {
        description = "List of overlays.";
        type = with types; listOf any;
        default = [ ];
      };
      extraConfig = mkOption {
        description = "Extra arguments passed to `import nixpkgs`. Merged with overlays and system.";
        default = { };
        type = with types; attrsOf inferred;
      };
      config = mkOption {
        description = "Arguments passed to `import nixpkgs`. Missing `system`.";
        default = { inherit (config.pkgsConfig) overlays; } // config.pkgsConfig.extraConfig;
        type = with types; attrsOf inferred;
      };
      nixpkgs = mkOption {
        description = "Nixpkgs flake input.";
        type = with types; any;
        default = self.inputs.nixpkgs;
      };
      _allNixpkgs = mkOption {
        default = genAttrs config.pkgsConfig.systems (system: import config.pkgsConfig.nixpkgs ({ inherit system; } // config.pkgsConfig.config));
        internal = true;
      };
    };
    pkgsFor = mkOption {
      description = "Function to generate pkgs set. Use the default value. Memorizes.";
      default = system: config.pkgsConfig._allNixpkgs.${system};
    };
  };
}
