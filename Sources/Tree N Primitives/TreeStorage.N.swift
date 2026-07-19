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

public import Index_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

// MARK: - TreeStorage.N — the BOUNDED-ARITY (n-ary) storage column
//
// `TreeStorage.N<Element, n>` is the n-ary tree's storage capability conformer
// ([DS-025]): a sparse `InlineArray<n, Handle?>` child-link representation (holes
// permitted) over the generational ``__TreeArena``. It is the `S` of the bounded-arity
// tree `__Tree<TreeStorage.N<Element, n>>` (the `Tree<Element>.N<n>` front door).
// Mirrors the landed `TreeStorage.Keyed` re-skeleton exactly — only the child-link
// representation differs: the keyed column uses the ordered keyed dictionary
// (addressed by `Key`), this column uses the sparse bounded slots (addressed by
// ``__TreeNChildSlot``).

extension TreeStorage {

    /// The bounded-arity (n-ary) tree storage column.
    ///
    /// Each node has at most `n` children in sparse slots (`InlineArray<n, Handle?>`,
    /// `nil` = empty slot; holes permitted), addressed by a bounded
    /// ``__TreeNChildSlot`` (`0..<n`). Inserting into an occupied slot fails with
    /// ``__TreeError/slotOccupied``.
    public struct N<Element: ~Copyable, let n: Int>: ~Copyable {

        /// Children are addressed by a bounded slot index (`0..<n`).
        public typealias Address = __TreeNChildSlot<n>

        /// The private generational arena (NON-PUBLIC — `@usableFromInline` for the
        /// inlinable witnesses).
        @usableFromInline
        var _arena: __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>

        /// Creates an empty n-ary column (move-only elements).
        @inlinable
        public init() {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>()
        }

        /// Creates an empty n-ary column with reserved capacity (move-only elements).
        @inlinable
        public init(minimumCapacity: Index<Element>.Count) {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>(
                minimumCapacity: minimumCapacity
            )
        }

        /// Creates an empty CoW-capable n-ary column (the clone strategy is captured here).
        @inlinable
        public init() where Element: Copyable {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>()
        }

        /// Creates an empty CoW-capable n-ary column with reserved capacity.
        @inlinable
        public init(minimumCapacity: Index<Element>.Count) where Element: Copyable {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>(
                minimumCapacity: minimumCapacity
            )
        }
    }
}

// MARK: - __TreeStorage conformance (the arena + sparse child-link witnesses)

extension TreeStorage.N: __TreeStorage where Element: ~Copyable {

    // MARK: Arena requirements (delegated to the private __TreeArena)

    /// The number of live nodes (typed — A3).
    @inlinable
    public var _count: Index<Element>.Count { _arena.count }

    /// The root node's handle.
    @inlinable
    public var _rootHandle: Store.Generational.Handle? {
        get { _arena.rootHandle }
        set { _arena.rootHandle = newValue }
    }

    /// Decodes a position to its live handle.
    @inlinable
    public func _liveHandle(_ position: __TreePosition) -> Store.Generational.Handle? {
        _arena.liveHandle(position)
    }

    /// Inserts a childless node (all-`nil` sparse links) with the given parent.
    @inlinable
    public mutating func _insertNode(
        _ element: consuming Element,
        parent: Store.Generational.Handle?
    ) -> Store.Generational.Handle {
        _arena.insertNode(
            element,
            links: InlineArray<n, Store.Generational.Handle?>(repeating: nil),
            parent: parent
        )
    }

    /// Removes a node, moving its element out.
    @inlinable
    public mutating func _removeNode(_ handle: Store.Generational.Handle) -> Element {
        _arena.removeNode(handle)
    }

    /// Removes every node and resets the root.
    @inlinable
    public mutating func _removeAll() { _arena.removeAll() }

    /// The parent handle of a node.
    @inlinable
    public func _parentHandle(of handle: Store.Generational.Handle) -> Store.Generational.Handle? {
        _arena.parentHandle(of: handle)
    }

    /// Borrowing access to a node's element.
    @inlinable
    public func _withElement<R: ~Copyable>(
        at handle: Store.Generational.Handle,
        _ body: (borrowing Element) -> R
    ) -> R {
        _arena.withElement(at: handle, body)
    }

    /// In-place (position-stable) mutating access to a node's element.
    @inlinable
    public mutating func _withElementMut<R: ~Copyable>(
        at handle: Store.Generational.Handle,
        _ body: (inout Element) -> R
    ) -> R {
        _arena.withElementMut(at: handle, body)
    }

    // MARK: Child-link requirements (sparse InlineArray<n, Handle?>)

    /// The child handle at a bounded slot, or `nil` if the slot is empty.
    @inlinable
    public func _childHandle(
        at handle: Store.Generational.Handle,
        address: __TreeNChildSlot<n>
    ) -> Store.Generational.Handle? {
        _arena.withLinks(at: handle) { $0[address.index] }
    }

    /// Rejects a child link into an occupied slot (the per-column error precision).
    @inlinable
    public func _validateLink(
        to parent: Store.Generational.Handle,
        at address: __TreeNChildSlot<n>
    ) throws(__TreeError) {
        let occupied = _arena.withLinks(at: parent) { $0[address.index] != nil }
        if occupied { throw .slotOccupied }
    }

    /// Links a child handle into a bounded slot (precondition: validated).
    @inlinable
    public mutating func _linkChild(
        _ child: Store.Generational.Handle,
        to parent: Store.Generational.Handle,
        at address: __TreeNChildSlot<n>
    ) {
        _arena.withLinksMut(at: parent) { $0[address.index] = child }
    }

    /// Clears the sparse slot holding `child` under `parent`.
    @inlinable
    public mutating func _unlinkChild(
        _ child: Store.Generational.Handle,
        from parent: Store.Generational.Handle
    ) {
        _arena.withLinksMut(at: parent) { links in
            for slot in 0..<n {
                if links[slot] == child {
                    links[slot] = nil
                    break
                }
            }
        }
    }

    /// The number of occupied child slots (sparse scan; `n` is compile-time bounded).
    @inlinable
    public func _childCount(at handle: Store.Generational.Handle) -> Int {
        _arena.withLinks(at: handle) { links in
            var count = 0
            for slot in 0..<n {
                if links[slot] != nil { count += 1 }
            }
            return count
        }
    }

    /// Visits each occupied child handle in slot order (left-to-right).
    @inlinable
    public func _forEachChild(
        at handle: Store.Generational.Handle,
        _ body: (Store.Generational.Handle) -> Void
    ) {
        _arena.withLinks(at: handle) { links in
            for slot in 0..<n {
                if let child = links[slot] { body(child) }
            }
        }
    }
}

// MARK: - __TreeNStorage conformance (the n-specific capability)

extension TreeStorage.N: __TreeNStorage where Element: ~Copyable {

    /// The maximum arity (number of child slots per node) — the column's `n`.
    @inlinable
    public static var _arity: Int { n }
}

// MARK: - Copyable / Sendable (flow from the element; the sparse links always carry)

extension TreeStorage.N: Copyable where Element: Copyable {}

extension TreeStorage.N: Sendable where Element: Sendable {}
