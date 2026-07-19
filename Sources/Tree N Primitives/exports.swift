// exports.swift
// Re-export dependencies for consumers.
//
// The n-ary tree surfaces `Tree` / `Tree.Position` (the shared tree-core carrier);
// the sparse-slot column vocabulary (`Column.Generational` / `Shared` /
// `Store.Generational.Handle`) is an INTERNAL detail of ``__TreeArena``, but the
// full spelling set is re-exported for consumer convenience alongside the tree core.

@_exported public import Column_Primitives
@_exported public import Index_Primitives
@_exported public import Ownership_Shared_Primitive
@_exported public import Queue_Primitives
@_exported public import Stack_Primitives
@_exported public import Storage_Generational_Primitives
@_exported public import Store_Primitive
@_exported public import Tree_Primitives
