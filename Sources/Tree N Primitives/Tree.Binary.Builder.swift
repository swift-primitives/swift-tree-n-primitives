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

// MARK: - Hoisted flat-BFS builder (module level)
//
// Hoisted per [API-EXC-001] (a result builder cannot nest in the generic carrier)
// and surfaced via the `Builder` nest alias on the binary carrier below.

/// A result builder for declaratively constructing binary trees.
///
/// Each declared element is positioned in BFS (level-order) layout:
/// the first element is the root, the next two are its left and right
/// children, the next four are their children in order, and so on.
/// This produces a *complete* binary tree from the declared sequence.
///
/// ```swift
/// let tree = Tree<Int>.Binary {
///     1     // root
///     2     // 1.left
///     3     // 1.right
///     4     // 2.left
///     5     // 2.right
///     6     // 3.left
///     7     // 3.right
/// }
/// ```
///
/// Resulting tree:
/// ```
///         1
///       /   \
///      2     3
///     / \   / \
///    4   5 6   7
/// ```
///
/// ## Sparse Trees
///
/// This builder constructs *complete* binary trees (each level is
/// fully filled). For sparse trees with missing children at specific
/// positions, use the imperative `insert(at:)` API directly, or the
/// nested DSL (``__TreeNNested``).
///
/// ## Element Constraint
///
/// The builder requires `Element: Copyable` because it uses
/// `Swift.Array<Element>` as its intermediate. ~Copyable element support
/// is a future ecosystem extension.
///
/// - Note: Use ``Tree/Binary/Builder`` in your code, not this type directly.
@resultBuilder
public enum __TreeNBuilder<Element> {

    // MARK: - Expression Building

    /// Wraps a single element expression into a one-element level-order array.
    @inlinable
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }

    /// Passes an already-built level-order array through unchanged.
    @inlinable
    public static func buildExpression(_ expression: [Element]) -> [Element] {
        expression
    }

    /// Bulk-add a sequence (Range, Set, lazy chain, etc.) without per-iteration allocation.
    ///
    /// Elements are placed in BFS level-order.
    @inlinable
    public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> [Element]
    where S.Element == Element {
        Array(expression)
    }

    /// Wraps an optional element expression, producing an empty array when it is `nil`.
    @inlinable
    public static func buildExpression(_ expression: Element?) -> [Element] {
        expression.map { [$0] } ?? []
    }

    // MARK: - Partial Block Building

    /// Begins a partial block with the first level-order array, passed through unchanged.
    @inlinable
    public static func buildPartialBlock(first: [Element]) -> [Element] {
        first
    }

    /// Begins a partial block from an empty first statement, producing an empty array.
    @inlinable
    public static func buildPartialBlock(first: Void) -> [Element] {
        []
    }

    /// Begins a partial block whose first component is statically unreachable.
    @inlinable
    public static func buildPartialBlock(first: Never) -> [Element] {}

    /// Merges an accumulated partial block with the next component, preserving
    /// declaration (BFS level) order.
    @inlinable
    public static func buildPartialBlock(
        accumulated: consuming [Element],
        next: [Element]
    ) -> [Element] {
        accumulated.append(contentsOf: next)
        return accumulated
    }

    // MARK: - Block Building

    /// Builds an empty level-order array for a block with no components.
    @inlinable
    public static func buildBlock() -> [Element] {
        []
    }

    // MARK: - Control Flow

    /// Builds from an optional `if`-branch component, producing an empty array when untaken.
    @inlinable
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }

    /// Builds the first branch of an `if`-`else` block.
    @inlinable
    public static func buildEither(first: [Element]) -> [Element] {
        first
    }

    /// Builds the second branch of an `if`-`else` block.
    @inlinable
    public static func buildEither(second: [Element]) -> [Element] {
        second
    }

    /// Flattens an array of per-iteration level-order arrays from a `for` loop.
    @inlinable
    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.flatMap { $0 }
    }

    /// Passes a component through unchanged for an availability-gated (`if #available`) branch.
    @inlinable
    public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
        component
    }
}

// MARK: - Tree.Binary.Builder — the nest alias onto the binary carrier

extension __Tree where S: __TreeNStorage, S.Address == __TreeNChildSlot<2>, S.Element: Copyable {

    /// The flat-BFS binary-tree result builder (``__TreeNBuilder``).
    public typealias Builder = __TreeNBuilder<S.Element>
}

// MARK: - Convenience Init

extension __Tree where S: ~Copyable {
    /// Constructs a complete binary tree from a result-builder closure.
    ///
    /// Elements are placed in BFS level-order: first = root, next two =
    /// root's children (left, right), next four = grandchildren, etc.
    ///
    /// ```swift
    /// let tree = Tree<Int>.Binary {
    ///     1
    ///     2
    ///     3
    ///     4
    ///     5
    /// }
    /// // Root: 1, left: 2, right: 3, 2.left: 4, 2.right: 5
    /// ```
    ///
    /// - Complexity: O(n) where n is the number of elements declared.
    @inlinable
    public init<Element>(
        @__TreeNBuilder<Element> _ builder: () -> [Element]
    ) where S == TreeStorage.N<Element, 2> {
        self.init()
        let elements = builder()
        guard !elements.isEmpty else { return }

        // Insert root.
        var positions: [__TreePosition] = []
        // WHY: `self.init()` just above guarantees a fresh, empty tree — `.root` can
        // never already be occupied.
        // swift-format-ignore: NeverUseForceTry
        // swiftlint:disable:next force_try
        try! positions.append(self.insert(elements[0], at: .root))

        // BFS level-order insert.
        var i = 1
        var parentIndex = 0
        while i < elements.count {
            let parent = positions[parentIndex]
            // Left child
            if i < elements.count {
                // WHY: `parentIndex` only ever advances forward, so each parent's left
                // slot is inserted into exactly once here — it can never already be occupied.
                // swift-format-ignore: NeverUseForceTry
                // swiftlint:disable:next force_try
                try! positions.append(self.insert(elements[i], at: .left(of: parent)))
                i += 1
            }
            // Right child
            if i < elements.count {
                // WHY: same reasoning as the left-child insert above — this parent's
                // right slot is inserted into exactly once, here.
                // swift-format-ignore: NeverUseForceTry
                // swiftlint:disable:next force_try
                try! positions.append(self.insert(elements[i], at: .right(of: parent)))
                i += 1
            }
            parentIndex += 1
        }
    }
}
