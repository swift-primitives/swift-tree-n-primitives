// exports.swift
// Inline ops module: re-export the Inline type module. `Tree.N.Inline` is
// unconditionally `~Copyable` and declares no Copyable-imposing conformance, so
// this module carries no isolated conformances — it exists to keep the
// `Tree_N_Inline_Primitives` (plural) consumer-import surface uniform with the
// other variants and to be re-exported by the umbrella.

@_exported public import Tree_N_Inline_Primitive
