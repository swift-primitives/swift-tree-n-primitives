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

// MARK: - N-ary InsertPosition convenience factories
//
// The bounded-arity tree's insert position IS the shared
// ``Tree/Protocol/InsertPosition`` (`__TreeInsertPosition<Address>` with
// `Address == __TreeNChildSlot<n>`), surfaced by the carrier's flow-through
// `InsertPosition` alias. There is no n-ary-specific insert-position type —
// only the arity-specific convenience factories below, which name child slots
// positionally and forward to `.child(of:at:)`.
//
// Per [TREE-010], `Tree<Element>.N<n>` provides no `.appendChild(of:)` — only the
// explicit slot factories — keeping bounded-arity semantics honest (no implicit
// slot selection).

// MARK: - Binary Tree Convenience (n == 2)

extension __TreeInsertPosition where Address == __TreeNChildSlot<2> {

    /// Insert as the left child of the given position.
    ///
    /// Convenience for `.child(of: position, at: .left)`.
    @inlinable
    public static func left(of position: __TreePosition) -> Self {
        .child(of: position, at: .left)
    }

    /// Insert as the right child of the given position.
    ///
    /// Convenience for `.child(of: position, at: .right)`.
    @inlinable
    public static func right(of position: __TreePosition) -> Self {
        .child(of: position, at: .right)
    }
}

// MARK: - Ternary Tree Convenience (n == 3)

extension __TreeInsertPosition where Address == __TreeNChildSlot<3> {

    /// Insert as the left child of the given position.
    @inlinable
    public static func left(of position: __TreePosition) -> Self {
        .child(of: position, at: .left)
    }

    /// Insert as the middle child of the given position.
    @inlinable
    public static func middle(of position: __TreePosition) -> Self {
        .child(of: position, at: .middle)
    }

    /// Insert as the right child of the given position.
    @inlinable
    public static func right(of position: __TreePosition) -> Self {
        .child(of: position, at: .right)
    }
}

// MARK: - Quad Tree Convenience (n == 4)

extension __TreeInsertPosition where Address == __TreeNChildSlot<4> {

    /// Insert as the northwest child of the given position.
    @inlinable
    public static func northwest(of position: __TreePosition) -> Self {
        .child(of: position, at: .northwest)
    }

    /// Insert as the northeast child of the given position.
    @inlinable
    public static func northeast(of position: __TreePosition) -> Self {
        .child(of: position, at: .northeast)
    }

    /// Insert as the southwest child of the given position.
    @inlinable
    public static func southwest(of position: __TreePosition) -> Self {
        .child(of: position, at: .southwest)
    }

    /// Insert as the southeast child of the given position.
    @inlinable
    public static func southeast(of position: __TreePosition) -> Self {
        .child(of: position, at: .southeast)
    }
}
