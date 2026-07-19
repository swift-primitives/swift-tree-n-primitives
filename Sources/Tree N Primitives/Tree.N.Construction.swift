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

public import Index_Primitives
public import Tree_Primitives

// MARK: - Column-pinned construction (the `Array+Columns` mechanic: method-level `where ==`)
//
// The carrier's construction pins to the n-ary column here (`init() where S ==
// TreeStorage.N<Element, n>`), so the `Tree<Element>.N<n>` front door gets the
// ergonomic empty / reserved-capacity inits. Mirrors the dynamic column's pinned
// construction (tree-core `TreeStorage.Dynamic.swift`).

extension __Tree where S: ~Copyable {

    /// Creates an empty n-ary tree (move-only elements).
    @inlinable
    public init<Element: ~Copyable, let n: Int>() where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>())
    }

    /// Creates an empty n-ary tree with reserved capacity (move-only elements).
    @inlinable
    public init<Element: ~Copyable, let n: Int>(
        minimumCapacity: Index_Primitives.Index<Element>.Count
    ) where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>(minimumCapacity: minimumCapacity))
    }

    // CoW construction twins (MEMBER-LEVEL): for a `Copyable` element the column's clone
    // strategy MUST be captured at construction (the `Shared` box's `Copyable` init), else
    // a copied tree's first mutation traps ("not unique but carries no clone strategy").
    // The more-constrained twin wins at `Copyable` call sites.

    /// Creates an empty CoW-capable n-ary tree (captures the clone strategy).
    @inlinable
    public init<Element, let n: Int>() where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>())
    }

    /// Creates an empty CoW-capable n-ary tree with reserved capacity.
    @inlinable
    public init<Element, let n: Int>(
        minimumCapacity: Index_Primitives.Index<Element>.Count
    ) where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>(minimumCapacity: minimumCapacity))
    }
}
