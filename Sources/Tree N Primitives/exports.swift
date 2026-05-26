// exports.swift
// Umbrella ([MOD-005] / [MOD-036] base-plural-as-umbrella): re-export the base
// type module plus every variant ops module. Each variant ops module in turn
// re-exports its own type module, so `import Tree_N_Primitives` surfaces the
// whole bounded-arity tree discipline.

@_exported public import Tree_N_Primitive
@_exported public import Tree_N_Bounded_Primitives
@_exported public import Tree_N_Inline_Primitives
@_exported public import Tree_N_Small_Primitives
