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

extension __TreeNNested {
    /// A result builder for declaratively constructing nested Tree.Binary nodes.
    ///
    /// Used in two roles:
    ///
    /// 1. **Outer body** of the convenience init: produces a single-element
    ///    array containing the root `Node`. Multiple top-level expressions
    ///    trap with a precondition (binary trees have one root).
    ///
    /// 2. **Children block** inside `Node(_:children:)`: produces 0, 1, or
    ///    2 child Nodes. The first becomes the `.left` slot, the second
    ///    becomes the `.right` slot. More than 2 traps.
    ///
    /// The same builder enum serves both contexts — the constraint
    /// (one vs two-or-fewer) is enforced at the consumer (the convenience
    /// init or `Node.init`).
    ///
    /// ```swift
    /// let tree = Tree<Int>.Binary.Nested {
    ///     Node(1) {
    ///         Node(2) {
    ///             Node(4)
    ///             Node(5)
    ///         }
    ///         Node(3)
    ///     }
    /// }
    /// ```
    @resultBuilder
    public enum Builder {

        // MARK: - Expression Building

        /// Wraps a single node expression into a one-element array.
        @inlinable
        public static func buildExpression(_ expression: Node) -> [Node] {
            [expression]
        }

        /// Passes an already-built node array through unchanged.
        @inlinable
        public static func buildExpression(_ expression: [Node]) -> [Node] {
            expression
        }

        /// Wraps an optional node expression, producing an empty array when it is `nil`.
        @inlinable
        public static func buildExpression(_ expression: Node?) -> [Node] {
            expression.map { [$0] } ?? []
        }

        // MARK: - Partial Block Building

        /// Begins a partial block with the first node array, passed through unchanged.
        @inlinable
        public static func buildPartialBlock(first: [Node]) -> [Node] {
            first
        }

        /// Begins a partial block from an empty first statement, producing an empty array.
        @inlinable
        public static func buildPartialBlock(first: Void) -> [Node] {
            []
        }

        /// Begins a partial block whose first component is statically unreachable.
        @inlinable
        public static func buildPartialBlock(first: Never) -> [Node] {}

        /// Merges an accumulated partial block with the next component, preserving
        /// declaration order.
        @inlinable
        public static func buildPartialBlock(
            accumulated: [Node],
            next: [Node]
        ) -> [Node] {
            accumulated + next
        }

        // MARK: - Block Building

        /// Builds an empty node array for a block with no components.
        @inlinable
        public static func buildBlock() -> [Node] {
            []
        }

        // MARK: - Control Flow

        /// Builds from an optional `if`-branch component, producing an empty array when untaken.
        @inlinable
        public static func buildOptional(_ component: [Node]?) -> [Node] {
            component ?? []
        }

        /// Builds the first branch of an `if`-`else` block.
        @inlinable
        public static func buildEither(first: [Node]) -> [Node] {
            first
        }

        /// Builds the second branch of an `if`-`else` block.
        @inlinable
        public static func buildEither(second: [Node]) -> [Node] {
            second
        }

        /// Flattens an array of per-iteration node arrays from a `for` loop.
        @inlinable
        public static func buildArray(_ components: [[Node]]) -> [Node] {
            components.flatMap { $0 }
        }

        /// Passes a component through unchanged for an availability-gated (`if #available`) branch.
        @inlinable
        public static func buildLimitedAvailability(_ component: [Node]) -> [Node] {
            component
        }
    }
}

// MARK: - Convenience Init

extension __Tree where S: ~Copyable {
    /// Constructs a Tree.Binary from a nested-DSL builder closure.
    ///
    /// The body declares exactly one root `Node`. Each Node may have 0, 1,
    /// or 2 children declared via `Node(value) { ... }`. First child →
    /// `.left`, second child → `.right`.
    ///
    /// Trapping preconditions:
    /// - Body must declare exactly 0 or 1 root nodes (zero = empty tree).
    /// - Each Node may have at most 2 children.
    ///
    /// ```swift
    /// let tree = Tree<Int>.Binary.Nested {
    ///     Node(1) {
    ///         Node(2)
    ///         Node(3)
    ///     }
    /// }
    /// ```
    ///
    /// - Complexity: O(n) where n is the number of nodes declared.
    ///
    /// - Note: Marked `@_disfavoredOverload` so empty-body call sites
    ///   (`Tree<Int>.N<2> { }`) and Element-literal call sites
    ///   (`Tree<Int>.N<2> { 1; 2; 3 }`) resolve to the flat-BFS
    ///   builder. Node-literal call sites
    ///   (`Tree<Int>.N<2> { Node(1) { ... } }`) still resolve here,
    ///   since the flat builder cannot accept Node expressions.
    @inlinable
    @_disfavoredOverload
    public init<Element>(
        @__TreeNNested<Element>.Builder _ builder: () -> [__TreeNNested<Element>.Node]
    ) where S == TreeStorage.N<Element, 2> {
        let roots = builder()
        precondition(
            roots.count <= 1,
            "Tree.Binary.Nested builder must declare at most 1 root node"
        )
        self.init()
        guard let root = roots.first else { return }
        // WHY: `self.init()` just above guarantees a fresh, empty tree — `.root` can
        // never already be occupied.
        // swift-format-ignore: NeverUseForceTry
        // swiftlint:disable:next force_try
        let rootPos = try! self.insert(root.element, at: .root)
        Self._insertChildren(root.children, parent: rootPos, into: &self)
    }

    @inlinable
    package static func _insertChildren<Element>(
        _ children: [__TreeNNested<Element>.Node],
        parent: __TreePosition,
        into tree: inout __Tree<TreeStorage.N<Element, 2>>
    ) where S == TreeStorage.N<Element, 2> {
        if children.count >= 1 {
            let leftNode = children[0]
            // WHY: each `Node` contributes at most one left child, inserted exactly
            // once here — `parent`'s left slot can never already be occupied.
            // swift-format-ignore: NeverUseForceTry
            // swiftlint:disable:next force_try
            let leftPos = try! tree.insert(leftNode.element, at: .left(of: parent))
            _insertChildren(leftNode.children, parent: leftPos, into: &tree)
        }
        if children.count >= 2 {
            let rightNode = children[1]
            // WHY: same reasoning as the left-child insert above — this parent's
            // right slot is inserted into exactly once, here.
            // swift-format-ignore: NeverUseForceTry
            // swiftlint:disable:next force_try
            let rightPos = try! tree.insert(rightNode.element, at: .right(of: parent))
            _insertChildren(rightNode.children, parent: rightPos, into: &tree)
        }
    }
}
