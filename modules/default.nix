{ devshell, ... }: rec {
  default = {
    imports = [ pkgs devshell.flakeModule ];
  };
  pkgs = import ./pkgs.nix;
}
