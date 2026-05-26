// exports.swift
// Inline type module re-exports: the base `Tree N Primitive` (Tree.N namespace +
// shared Node/ChildSlot/InsertPosition) plus the inline arena backing.
// `Tree.N.Inline` is unconditionally `~Copyable` (@_rawLayout storage) — it has
// no Copyable/Sequence conformance, so there is no ops module to isolate.

@_exported public import Tree_N_Primitive
@_exported public import Buffer_Arena_Inline_Primitives
