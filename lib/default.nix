pkgs
#  ,inputs 
: rec {

  # # [a] -> (a -> { name: String; value: Any }) -> AttrSet
  genAttrsAux = as: f: builtins.foldl' (set: a: set // (let fa = f a; in { ${fa.name} = fa.value; })) { } as;

  # [a] -> (a -> AttrSet) -> AttrSet
  concatMapAttrSets = as: f: builtins.foldl' (set: a: set // f a) { } as;

  concatFiles = pkgs.lib.strings.concatMap builtins.readFile;

  # Recurse into the attrset and return all values that are not attrsets.
  # AttrSet -> [Any]
  flattenAttrset = atrs: builtins.concatMap (x: if builtins.isAttrs x then flattenAttrset x else [ x ]) (lib.attrsets.attrValues atrs);

  ifd = cmd: import (pkgs.runCommand "ifd-for-${cmd}" { } cmd);

  # Derviation producing directory like that:
  # mkDir {"offchain/src" : [some_derivation, other_derivation];
  #        "offchain": [./offchain]}
  # = 
  # /
  #   - offchain/
  #     - src/
  #       - some_derivation
  #       - other_derivation
  #     - ...
  # used instead of symlinkJoin, because https://github.com/nix-community/dream2nix/issues/520
  mkDir = name: dir:
    pkgs.runCommand name { } (''
      mkdir res
    '' + (pkgs.lib.concatMapStrings
      (path:
        let
          copyCmd =
            if path == "" then
              (drv: ''
                cp -r ${drv}/* res
              '')
            else
              (drv: ''
                mkdir -p res/${path}
                chmod +w res/${path}
                cp -r ${drv}/* res/${path}
              '');
        in
        pkgs.lib.concatMapStrings copyCmd dir.${path})
      (builtins.attrNames dir)) + ''
      mkdir $out
      cp -r res/* $out
    '');

  # Used to add pre-commit packages and shell hook to the other project shells
  mergeShells = devshell-1: devshell-2:
    pkgs.mkShell {
      packages = [ ];

      inputsFrom = [ devshell-1 devshell-2 ];

      shellHook = devshell-1.shellHook + devshell-2.shellHook;
    };

  mergeShellList = shells: pkgs.mkShell {
    packages = [ ];

    inputsFrom = shells;

    shellHook = builtins.concatStringsSep "\n" (map (shell: shell.shellHook) shells);
  };
}
