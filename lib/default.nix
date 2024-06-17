lib: rec {

  # # [a] -> (a -> { name: String; value: Any }) -> AttrSet
  genAttrsAux = as: f: builtins.foldl' (set: a: set // (let fa = f a; in { ${fa.name} = fa.value; })) { } as;

  # [a] -> (a -> AttrSet) -> AttrSet
  concatMapAttrSets = as: f: builtins.foldl' (set: a: set // f a) { } as;

  concatFiles = lib.strings.concatMapStrings builtins.readFile;

  # Recurse into the attrset and return all values that are not attrsets.
  # AttrSet -> [Any]
  flattenAttrset = atrs: builtins.concatMap (x: if builtins.isAttrs x then flattenAttrset x else [ x ]) (lib.attrsets.attrValues atrs);

  #   ```
  #   recursiveUpdateConcat :: AttrSet -> AttrSet -> AttrSet
  #   ```
  #   
  #   Recursively merge attrsets but also concat lists.
  # 
  #   # Examples
  #   :::{.example}
  #   ## `lib.attrsets.recursiveUpdateConcat` usage example

  #   ```nix
  #   recursiveUpdateConcat {
  #     boot.loader.grub.enable = true;
  #     boot.loader.grub.devices = ["/dev/hda"];
  #   } {
  #     boot.loader.grub.devices = ["/dev/nvme"];
  #   }

  #   returns: {
  #     boot.loader.grub.enable = true;
  #     boot.loader.grub.devices = [ "/dev/hda" "/dev/nvme" ];
  #   }
  #   ```
  recursiveUpdateConcat =
    lhs:
    rhs:
    let
      f = with builtins;
        zipAttrsWith (n: values:
          if length values == 1 then
            head values
          else
            let
              fst = head values;
            in
            if isAttrs fst then
              f values # assuming all values are attrsets
            else if isList fst then
              concatLists values
            else # return leftmost
              head values
        );
    in
    f [ rhs lhs ];

}
