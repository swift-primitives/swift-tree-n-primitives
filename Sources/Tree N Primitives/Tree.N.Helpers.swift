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

public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

// MARK: - N-ary tree vocabulary + handle-level seams (the de-compounded port surface)
//
// The n-specific surface lives on the carrier constrained to the bounded-arity column
// capability (`extension __Tree where S: __TreeNStorage`). The shared insert / remove /
// navigation / traversal come from the tree-core `Tree+Operations` engine for free;
// these handle-level helpers re-anchor the n-ary algorithms' internal reads onto the
// column through the public `__Tree<S>._storage` seam, so the salvaged algorithm
// bodies carry forward with only their extension header changed. `_position(of:)` /
// `_liveHandle(_:)` are inherited from `Tree+Operations` and are NOT redefined here.

extension __Tree where S: __TreeNStorage & ~Copyable {

    /// A bounded child slot index (`0..<n`) — how a child is addressed within its parent.
    public typealias ChildSlot = S.Address

    /// The traversal-order sequence namespace (``__TreeNOrder``).
    public typealias Order = __TreeNOrder

    /// The maximum arity (number of child slots per node).
    @inlinable
    public static var arity: Int { S._arity }

    /// The root node's handle, or `nil` if the tree is empty.
    @usableFromInline
    var _rootHandle: Store.Generational.Handle? {
        @inlinable get { _storage._rootHandle }
        @inlinable set { _storage._rootHandle = newValue }
    }

    /// The parent handle of a node (`nil` for the root).
    @inlinable
    package func _parentHandle(of handle: Store.Generational.Handle) -> Store.Generational.Handle? {
        _storage._parentHandle(of: handle)
    }

    /// A node's occupied child handles, in slot order (left-to-right; holes skipped).
    @inlinable
    package func _childHandles(of handle: Store.Generational.Handle) -> [Store.Generational.Handle] {
        var children: [Store.Generational.Handle] = []
        _storage._forEachChild(at: handle) { children.append($0) }
        return children
    }

    /// The child handle at a bounded slot, or `nil` if the slot is empty.
    @inlinable
    package func _childHandle(
        of handle: Store.Generational.Handle,
        at address: S.Address
    ) -> Store.Generational.Handle? {
        _storage._childHandle(at: handle, address: address)
    }
}

// MARK: - Copyable-element handle seams

extension __Tree where S: __TreeNStorage, S.Element: Copyable {

    /// The element at a live handle.
    @inlinable
    package func _value(of handle: Store.Generational.Handle) -> S.Element {
        _storage._withElement(at: handle) { $0 }
    }
}
