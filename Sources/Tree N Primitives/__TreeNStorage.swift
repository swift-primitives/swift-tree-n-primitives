// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Tree_Primitives

// MARK: - __TreeNStorage — the N-ARY storage-column capability (refines __TreeStorage)
//
// The n-ary tree is `Tree<S>` over a bounded-arity column `S` ([DS-025]). The shared
// `__TreeStorage` seam already carries the arena + child-link ops every column needs;
// this refinement marks the bounded-arity family (the sparse `InlineArray<n, Handle?>`
// child links, addressed by `__TreeNChildSlot<n>`) and adds the one static read the
// n-specific surface needs — the compile-time arity.
//
// The address type CANNOT be constrained generically here (a protocol cannot bind the
// slot's value-generic `n`); each conformer pins `Address == __TreeNChildSlot<n>` at
// its own `n`. Binary-only surfaces constrain the concrete literal
// (`S.Address == __TreeNChildSlot<2>`), which needs no value-generic binding.
//
// The carrier's n-specific extensions constrain on this capability
// (`extension __Tree where S: __TreeNStorage`) and reach the column through the
// public `__Tree<S>._storage` accessor (the tree-core seam). Hoisted per [API-EXC-001].

/// The n-ary storage-column capability: `__TreeStorage` with a bounded slot address,
/// plus the compile-time arity read.
///
/// The `Error == __TreeError` refinement pins the column's error witness to the shared
/// tree error (the bounded-arity column adds no key-carrying cases): in every
/// `extension __Tree where S: __TreeNStorage` the carrier's flow-through `Self.Error`
/// is therefore CONCRETELY ``__TreeError``.
public protocol __TreeNStorage: __TreeStorage, ~Copyable where Error == __TreeError {
    /// The maximum arity (number of child slots per node) — the column's `n`.
    static var _arity: Int { get }
}
