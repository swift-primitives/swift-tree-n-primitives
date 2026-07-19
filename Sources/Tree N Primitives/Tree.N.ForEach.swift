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

public import Property_Primitives
public import Stack_Primitives
public import Tree_Primitives

// MARK: - Tree.N forEach.inOrder (binary; R1 W4 [API-NAME-002])
//
// The legacy `forEachInOrder` (n == 2) folds into the shared `forEach` view as
// `tree.forEach.inOrder { }`. Bound to the binary tree-n conformer via
// `Base.Address == __TreeNChildSlot<2>` — the literal `2` needs no value-generic
// binding. Walks positions over the `Tree.Protocol` view-facing requirements
// (`root` / `_child(of:at:)` / `_liveHandle` / `_withElement`) — the conformer's
// concrete column is not visible through the protocol-generic view.

extension Property_Primitives.Property.Borrow
where Base: __TreeProtocol & ~Copyable, Tag == __TreeForEach, Base.Address == __TreeNChildSlot<2> {
    /// Visits every element in in-order (left subtree, root, right subtree).
    ///
    /// Binary trees only (`Tree.N<2>` / `Tree.Binary`). Iterative (deep-tree safe).
    @inlinable
    public func inOrder(_ body: (borrowing Base.Element) -> Void) {
        guard let root = base.value.root else { return }
        var pending = Stack<__TreePosition>()
        var current: __TreePosition? = root

        while current != nil || !pending.isEmpty {
            // Walk to the leftmost node.
            while let c = current {
                pending.push(c)
                current = base.value._child(of: c, at: .left)
            }
            // Visit the node, then move into its right subtree.
            guard let c = pending.pop() else { break }
            if let handle = base.value._liveHandle(c) {
                base.value._withElement(at: handle) { body($0) }
            }
            current = base.value._child(of: c, at: .right)
        }
    }
}
