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

// MARK: - Hoisted n-ary traversal-order namespace (module level)
//
// The n-ary tree's value-`Sequence` traversal views. The shared closure traversal
// (`tree.forEach.preOrder { }`) is inherited from the tree-core engine; these views
// are the `Iterable` / `Sequenceable` collection path (`Array(tree.preOrder)`).
// Hoisted and generic over the n-ary column `S` (per [API-EXC-001], like
// ``__TreeNChildSlot``): they cannot nest in the generic `Tree<S>`, and the
// column-nested alternative would block the `tree.preOrder` property accessor.
// Surfaced as the ``Tree/N/Order`` nest alias on the carrier.

/// Namespace for the n-ary tree's traversal-order sequence views.
///
/// - ``Pre``: pre-order (root, then children in slot order)
/// - ``Post``: post-order (children in slot order, then root)
/// - ``Level``: level-order (breadth-first)
/// - ``In``: in-order (left, root, right) — binary trees only
public enum __TreeNOrder {}
