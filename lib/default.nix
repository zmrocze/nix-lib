lib: rec {

  # # [a] -> (a -> { name: String; value: Any }) -> AttrSet
  genAttrsAux = as: f: builtins.foldl' (set: a: set // (let fa = f a; in { ${fa.name} = fa.value; })) { } as;

  # [a] -> (a -> AttrSet) -> AttrSet
  concatMapAttrSets = as: f: builtins.foldl' (set: a: set // f a) { } as;

  concatFiles = strings.concatMap builtins.readFile;

  # Recurse into the attrset and return all values that are not attrsets.
  # AttrSet -> [Any]
  flattenAttrset = atrs: builtins.concatMap (x: if builtins.isAttrs x then flattenAttrset x else [ x ]) (lib.attrsets.attrValues atrs);

}
