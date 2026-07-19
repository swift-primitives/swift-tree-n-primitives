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

// MARK: - Tree<Element>.N<n> — the BOUNDED-ARITY-column front door ([DS-028])

extension __Tree where S: ~Copyable, S: __TreeStorage {

    /// The bounded-arity (n-ary) tree: the family carrier over the sparse-slot column.
    ///
    /// A column-selection front-door alias ([DS-028], the D4.1 sibling-column sense):
    /// it re-parameterizes the carrier onto `TreeStorage.N`, inheriting `Element`
    /// (`S.Element`) from the family member it is named on — `Tree<Int>.N<2>`
    /// resolves through the canonical alias to `__Tree<TreeStorage.N<Int, 2>>`,
    /// fully specialized, zero forwarding. Children are addressed by a bounded
    /// ``__TreeNChildSlot`` (`0..<n`) rather than by dense child index; the n-ary
    /// column is a SIBLING column with its own package, not a variant axis of the
    /// dynamic column.
    ///
    /// The `where S: ~Copyable` restatement keeps the alias reachable from move-only
    /// columns (the M1 alias-reachability discipline); `S: __TreeStorage` supplies
    /// `S.Element`.
    ///
    /// ```swift
    /// var tree = Tree<Int>.N<2>()
    /// let root = try tree.insert(1, at: .root)
    /// let left = try tree.insert(2, at: .left(of: root))
    /// ```
    public typealias N<let n: Int> = __Tree<TreeStorage.N<S.Element, n>>

    /// A binary tree — `Tree<Element>.N<2>`.
    ///
    /// The binary door carries the slot vocabulary (`.left` / `.right`), the
    /// `left(of:)` / `right(of:)` navigation, in-order traversal
    /// (`forEach.inOrder` / `inOrder`), and the two builders (flat BFS + nested DSL).
    public typealias Binary = __Tree<TreeStorage.N<S.Element, 2>>
}
