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

public import Tree_N_Primitive

// MARK: - Swift.Sequence Conformances (isolated per [MOD-004] / [MOD-036])
//
// The `Tree.N.Order.*.Sequence` structs, their `makeIterator()`, and the
// storage-touching `@inlinable` Order iterators are co-located with the arena
// storage in the `Tree N Primitive` type module (handoff MUST + [MOD-036]:
// internal `@usableFromInline` storage + cross-module `@inlinable` would fail).
// Only the Copyable-imposing `Swift.Sequence` conformance is isolated here so
// the lean `~Copyable` type surface stays poison-free per [MOD-004].

extension Tree.N.Order.Pre.Sequence: Swift.Sequence {}
extension Tree.N.Order.Post.Sequence: Swift.Sequence {}
extension Tree.N.Order.Level.Sequence: Swift.Sequence {}
extension Tree.N.Order.In.Sequence: Swift.Sequence {}
