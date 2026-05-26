// exports.swift
// Small type module re-exports: the base `Tree N Primitive` (Tree.N namespace +
// shared Node/ChildSlot/InsertPosition) plus the inline arena backing.
// `Tree.N.Small` is unconditionally `~Copyable` (inline storage with heap spill).

@_exported public import Tree_N_Primitive
@_exported public import Buffer_Arena_Inline_Primitives
