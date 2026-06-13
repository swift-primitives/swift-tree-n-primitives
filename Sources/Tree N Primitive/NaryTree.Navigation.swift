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

public import Tree_Primitives_Core

// MARK: - Sparse-slot navigation (NaryTree-specific; over the shared child(of:at:))

extension NaryTree where Element: ~Copyable {

    /// The position of the leftmost (first non-empty) child, or `nil` if there are none.
    @inlinable
    public func leftmostChild(of position: __TreePosition) -> __TreePosition? {
        for raw in 0..<n {
            if let slot = __TreeNChildSlot<n>(raw), let child = child(of: position, at: slot) {
                return child
            }
        }
        return nil
    }

    /// The position of the rightmost (last non-empty) child, or `nil` if there are none.
    @inlinable
    public func rightmostChild(of position: __TreePosition) -> __TreePosition? {
        for raw in stride(from: n - 1, through: 0, by: -1) {
            if let slot = __TreeNChildSlot<n>(raw), let child = child(of: position, at: slot) {
                return child
            }
        }
        return nil
    }
}

// MARK: - Binary navigation (n == 2)

extension NaryTree where Element: ~Copyable, n == 2 {

    /// The position of the left child (slot 0), or `nil`.
    @inlinable
    public func left(of position: __TreePosition) -> __TreePosition? {
        child(of: position, at: .left)
    }

    /// The position of the right child (slot 1), or `nil`.
    @inlinable
    public func right(of position: __TreePosition) -> __TreePosition? {
        child(of: position, at: .right)
    }
}
