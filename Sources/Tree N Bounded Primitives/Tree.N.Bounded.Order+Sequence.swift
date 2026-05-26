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

public import Tree_N_Bounded_Primitive

// MARK: - Swift.Sequence Conformances (isolated per [MOD-004] / [MOD-036])
//
// The `Tree.N.Bounded.Order.*.Sequence` structs + their `makeIterator()` + the
// storage-touching `@inlinable` iterators are co-located with the Bounded arena
// storage in the `Tree N Bounded Primitive` type module. Only the
// Copyable-imposing `Swift.Sequence` conformance is isolated here.

extension Tree.N.Bounded.Order.Pre.Sequence: Swift.Sequence {}
extension Tree.N.Bounded.Order.Post.Sequence: Swift.Sequence {}
extension Tree.N.Bounded.Order.Level.Sequence: Swift.Sequence {}
extension Tree.N.Bounded.Order.In.Sequence: Swift.Sequence {}
