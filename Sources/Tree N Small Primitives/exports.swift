// exports.swift
// Small ops module: re-export the Small type module. `Tree.N.Small` is
// unconditionally `~Copyable` and declares no Copyable-imposing conformance, so
// this module carries no isolated conformances — uniform plural surface +
// umbrella re-export, mirroring the Inline variant.

@_exported public import Tree_N_Small_Primitive
