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

// MARK: - Hoisted ChildSlot Type (Module Level)
//
// The bounded child-slot address of the n-ary column. Hoisted to module level per
// [API-EXC-001] (a value-generic type cannot nest in the generic carrier) and
// surfaced via the `Tree<Element>.N<n>.ChildSlot` nest alias on the carrier.

/// Hoisted implementation of ``Tree/N/ChildSlot``.
///
/// Represents a statically bounded child slot index for n-ary trees.
/// Valid slot indices are in the range `0..<n`.
///
/// ## Sparse Slot Semantics
///
/// Per [TREE-003], `Tree<Element>.N<n>` uses sparse child slots: each node stores
/// `InlineArray<n, Handle?>` where `nil` denotes an empty slot. Holes are
/// permitted. This type ensures slot indices are within bounds at construction time.
///
/// - Note: Use ``Tree/N/ChildSlot`` in your code, not this type directly.
public struct __TreeNChildSlot<let n: Int>: Sendable, Equatable, Hashable {

    /// The slot index within the range `0..<n`.
    public let index: Int

    /// Creates a child slot from a raw index, or `nil` if `index` is out of bounds.
    ///
    /// - Parameter index: The slot index. Must be in range `0..<n`.
    @inlinable
    public init?(_ index: Int) {
        guard index >= 0 && index < n else { return nil }
        self.index = index
    }

    /// Creates a child slot without bounds checking.
    ///
    /// - Warning: The caller must ensure `index` is in range `0..<n`.
    @usableFromInline
    init(__unchecked index: Int) {
        self.index = index
    }
}

// MARK: - Binary Tree Convenience (n == 2)

extension __TreeNChildSlot where n == 2 {

    /// The left child slot (index 0).
    @inlinable
    public static var left: Self { Self(__unchecked: 0) }

    /// The right child slot (index 1).
    @inlinable
    public static var right: Self { Self(__unchecked: 1) }
}

// MARK: - Ternary Tree Convenience (n == 3)

extension __TreeNChildSlot where n == 3 {

    /// The left child slot (index 0).
    @inlinable
    public static var left: Self { Self(__unchecked: 0) }

    /// The middle child slot (index 1).
    @inlinable
    public static var middle: Self { Self(__unchecked: 1) }

    /// The right child slot (index 2).
    @inlinable
    public static var right: Self { Self(__unchecked: 2) }
}

// MARK: - Quad Tree Convenience (n == 4)

extension __TreeNChildSlot where n == 4 {

    /// The northwest child slot (index 0).
    @inlinable
    public static var northwest: Self { Self(__unchecked: 0) }

    /// The northeast child slot (index 1).
    @inlinable
    public static var northeast: Self { Self(__unchecked: 1) }

    /// The southwest child slot (index 2).
    @inlinable
    public static var southwest: Self { Self(__unchecked: 2) }

    /// The southeast child slot (index 3).
    @inlinable
    public static var southeast: Self { Self(__unchecked: 3) }
}

// MARK: - CustomStringConvertible

extension __TreeNChildSlot: CustomStringConvertible {
    /// A textual representation of the slot, such as `"ChildSlot(0)"`.
    public var description: String {
        "ChildSlot(\(index))"
    }
}
