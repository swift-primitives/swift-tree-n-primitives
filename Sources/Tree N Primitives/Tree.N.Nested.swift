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

// MARK: - Hoisted nested-DSL namespace (module level)
//
// Hoisted per [API-EXC-001] (a namespace generic over the element cannot nest in the
// generic carrier) and surfaced via the `Nested` nest alias on the binary carrier.

/// Namespace for the nested-DSL Tree.Binary builder.
///
/// Provides a recursive, nestable builder where each node can have left/right
/// children declared as nested expressions. Coexists with the flat-BFS
/// ``__TreeNBuilder`` — choose the flat builder for *complete* binary trees
/// declared in level order; choose the nested builder for *sparse* trees with
/// explicit left/right placement.
///
/// ```swift
/// let tree = Tree<Int>.Binary.Nested {
///     Node(1) {
///         Node(2) {
///             Node(4)
///             Node(5)
///         }
///         Node(3) {
///             Node(6)
///         }
///     }
/// }
/// ```
///
/// - Note: Use ``Tree/N/Nested`` in your code, not this type directly.
public enum __TreeNNested<Element> {}

// MARK: - Tree.N.Nested — the nest alias onto the binary carrier

extension __Tree where S: __TreeNStorage, S.Address == __TreeNChildSlot<2>, S.Element: Copyable {

    /// The nested-DSL builder namespace (``__TreeNNested``): declarative
    /// sparse binary-tree construction with explicit left/right placement.
    public typealias Nested = __TreeNNested<S.Element>
}
