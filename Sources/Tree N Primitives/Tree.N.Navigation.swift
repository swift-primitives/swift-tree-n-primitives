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

// MARK: - Binary Tree Navigation Convenience (n == 2; over the shared `_child(of:at:)`)
//
// Bound to the binary column via `S.Address == __TreeNChildSlot<2>` — the literal `2`
// needs no value-generic binding.

extension __Tree where S: __TreeNStorage & ~Copyable, S.Address == __TreeNChildSlot<2> {

    /// The position of the left child, or `nil` if there is no left child / the
    /// position is invalid.
    @inlinable
    public func left(of position: Position) -> Position? {
        _child(of: position, at: .left)
    }

    /// The position of the right child, or `nil` if there is no right child / the
    /// position is invalid.
    @inlinable
    public func right(of position: Position) -> Position? {
        _child(of: position, at: .right)
    }
}

// MARK: - Folded into fluent accessors (R1 W4 [API-NAME-002])
//
// `leftmostChild` / `rightmostChild` → the shared `tree.child.leftmost(of:)` /
// `.rightmost(of:)` view members (tree-core `__TreeChild.swift`, generalized to
// first/last child of any ordered tree). `forEachInOrder` → `tree.forEach.inOrder { }`
// (binary only) in `Tree.N.ForEach.swift`.
