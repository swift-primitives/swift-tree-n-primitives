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

/// A binary tree — the canonical 2-ary `NaryTree`.
///
/// `BinaryTree<Element>` is the module-scope spelling of `NaryTree<Element, 2>`
/// (the namespace-dissolved successor to `Tree.Binary`). It carries the binary
/// conveniences: `.left`/`.right` slots and insert positions, `left(of:)`/
/// `right(of:)` navigation, and `forEachInOrder`.
public typealias BinaryTree<Element: ~Copyable> = NaryTree<Element, 2>
