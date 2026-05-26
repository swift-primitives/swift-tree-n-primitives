// exports.swift
// Type module re-exports ([MOD-036]): surfaces the `Tree` namespace shell
// (Tree, Tree.Index, Tree.Position) from Tree_Primitives_Core plus the
// arena/queue/stack backings the bounded-arity surface composes. Module-wide
// visibility for the storage-touching files co-located here.

@_exported public import Tree_Primitives_Core
@_exported public import Buffer_Arena_Primitives
@_exported public import Index_Primitives
@_exported public import Queue_Primitives_Core
@_exported public import Stack_Primitives
