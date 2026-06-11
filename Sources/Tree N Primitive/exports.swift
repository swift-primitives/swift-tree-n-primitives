// exports.swift
// Type module re-exports ([MOD-036]): surfaces the `Tree` namespace shell
// (Tree, Tree.Index, Tree.Position) from Tree_Primitives_Core plus the
// generational-column/queue/stack backings the bounded-arity surface composes
// (`Node`'s public surface embeds `Store.Generational.Handle`). Module-wide
// visibility for the storage-touching files co-located here.

@_exported public import Tree_Primitives_Core
@_exported public import Store_Primitive
@_exported public import Storage_Generational_Primitives
@_exported public import Shared_Primitive
@_exported public import Column_Primitives
@_exported public import Index_Primitives
@_exported public import Queue_Primitives
@_exported public import Stack_Primitives
