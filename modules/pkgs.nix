# flake part module for defining pkgs
{ config, lib, self, ... }: {
  options = with lib; {
    pkgsConfig = {
      systems = mkOption {
        type = with types; listOf str;
        # default = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        default = config.systems;
        description = ''
          The systems to build pkgs for.
        '';
      };
      overlays = mkOption {
        description = "List of overlays.";
        type = with types; listOf raw; # important to avoid infinite recursion when merging option
        default = [ ];
      };
      extraConfig = mkOption {
        description = "Extra arguments passed to `import nixpkgs`. Merged with overlays and system.";
        default = { };
        type = with types; attrsOf anything;
      };
      config = mkOption {
        description = "Arguments passed to `import nixpkgs`. Missing `system`.";
        default = { inherit (config.pkgsConfig) overlays; } // config.pkgsConfig.extraConfig;
        type = types.raw; # for good measure, if you set this you're overwritting and dont want options merged. 
      };
      nixpkgs = mkOption {
        description = "Nixpkgs flake input.";
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

  config = {
    perSystem = { system, ... }: {
      _module.args.pkgs = config.pkgsFor system;
    };
  };

}
