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

public import Tree_Primitives_Core

// MARK: - NaryTree insert-position conveniences
//
// NaryTree uses the shared `__TreeInsertPosition<Address>` with `Address ==
// ChildSlot<n>` (so `.root` and `.child(of:at:)` come for free). The named-slot
// conveniences (`.left(of:)`, `.northwest(of:)`, …) re-anchor here as constrained
// extensions per arity. Per [TREE-010] there is no `.appendChild` (bounded arity).

extension __TreeInsertPosition where Address == __TreeNChildSlot<2> {
    /// Insert as the left child (slot 0).
    @inlinable
    public static func left(of position: __TreePosition) -> Self { .child(of: position, at: .left) }

    /// Insert as the right child (slot 1).
    @inlinable
    public static func right(of position: __TreePosition) -> Self { .child(of: position, at: .right) }
}

extension __TreeInsertPosition where Address == __TreeNChildSlot<3> {
    /// Insert as the left child (slot 0).
    @inlinable
    public static func left(of position: __TreePosition) -> Self { .child(of: position, at: .left) }

    /// Insert as the middle child (slot 1).
    @inlinable
    public static func middle(of position: __TreePosition) -> Self { .child(of: position, at: .middle) }

    /// Insert as the right child (slot 2).
    @inlinable
    public static func right(of position: __TreePosition) -> Self { .child(of: position, at: .right) }
}

extension __TreeInsertPosition where Address == __TreeNChildSlot<4> {
    /// Insert as the northwest child (slot 0).
    @inlinable
    public static func northwest(of position: __TreePosition) -> Self { .child(of: position, at: .northwest) }

    /// Insert as the northeast child (slot 1).
    @inlinable
    public static func northeast(of position: __TreePosition) -> Self { .child(of: position, at: .northeast) }

    /// Insert as the southwest child (slot 2).
    @inlinable
    public static func southwest(of position: __TreePosition) -> Self { .child(of: position, at: .southwest) }

    /// Insert as the southeast child (slot 3).
    @inlinable
    public static func southeast(of position: __TreePosition) -> Self { .child(of: position, at: .southeast) }
}
