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

// MARK: - Traversal Sequences (Copyable elements only)
//
// The closure-based `forEach.preOrder { }` / `.postOrder { }` / `.levelOrder { }` are
// INHERITED from the shared tree-core engine (shape-agnostic). These properties surface
// the `Iterable`/`Sequenceable` traversal VIEWS — the canonical collection path
// (`Array(tree.preOrder)` / `tree.preOrder.reduce(into:)`).

extension __Tree where S: __TreeNStorage, S.Element: Copyable {

    /// A sequence that yields elements in pre-order (root, then children in slot order).
    public var preOrder: __TreeNOrder.Pre.Sequence<S> {
        __TreeNOrder.Pre.Sequence<S>(tree: self)
    }

    /// A sequence that yields elements in post-order (children in slot order, then root).
    public var postOrder: __TreeNOrder.Post.Sequence<S> {
        __TreeNOrder.Post.Sequence<S>(tree: self)
    }

    /// A sequence that yields elements in level-order (breadth-first).
    public var levelOrder: __TreeNOrder.Level.Sequence<S> {
        __TreeNOrder.Level.Sequence<S>(tree: self)
    }
}

// MARK: - Binary Tree In-Order Sequence (n == 2 only)

extension __Tree where S: __TreeNStorage, S.Element: Copyable, S.Address == __TreeNChildSlot<2> {

    /// A sequence that yields elements in in-order (left, root, right).
    ///
    /// Only available for binary trees (n == 2).
    public var inOrder: __TreeNOrder.In.Sequence<S> {
        __TreeNOrder.In.Sequence<S>(tree: self)
    }
}
