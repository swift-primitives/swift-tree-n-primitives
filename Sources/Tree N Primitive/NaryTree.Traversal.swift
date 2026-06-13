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

public import Stack_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive

// MARK: - Binary in-order traversal (n == 2; NaryTree-specific)
//
// Pre/post/level-order are shared (the Tree.Protocol defaults). In-order is
// binary-only — it lives here, expressed over the public operation requirements
// (`_rootHandle` / `_childHandle(at:address:)` / `_withElement`), never raw storage.

extension NaryTree where Element: ~Copyable, n == 2 {

    /// Visits every element in in-order (left subtree, root, right subtree).
    ///
    /// Only available for binary trees (`n == 2`). Iterative (deep-tree safe).
    @inlinable
    public func forEachInOrder(_ body: (borrowing Element) -> Void) {
        guard let rootHandle = _rootHandle else { return }
        var pending = Stack<Store.Generational.Handle>()
        var current: Store.Generational.Handle? = rootHandle
        while current != nil || !pending.isEmpty {
            while let node = current {
                pending.push(node)
                current = _childHandle(at: node, address: .left)
            }
            guard let node = pending.pop() else { break }
            _withElement(at: node) { body($0) }
            current = _childHandle(at: node, address: .right)
        }
    }
}
