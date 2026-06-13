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
public import Tree_Primitives_Core

/// A bounded-arity tree with sparse, statically-sized child slots — the
/// `Tree.Protocol` conformer whose nodes hold an `InlineArray<n, Handle?>`.
///
/// `NaryTree<Element, n>` gives each node at most `n` children in fixed slots
/// (`0..<n`); empty slots are holes (sparse, per [TREE-003]). Children are
/// addressed by the type-safe ``ChildSlot`` (so `n == 2` gets `.left`/`.right`,
/// `n == 4` gets `.northwest`/…). Both the tree and its elements may be
/// `~Copyable`; when `Element` is `Copyable` the tree is copy-on-write.
///
/// The arena, decode (Round M B2), token validation, typed counts (A3), the
/// position-survives-growth contract and the shared tree algorithms live in
/// `TreeStorage` + the `Tree.Protocol` defaults; this type supplies only the
/// sparse `InlineArray` child-link representation and its operations.
///
/// ## Example
///
/// ```swift
/// var tree = NaryTree<Int, 2>()
/// let root = try tree.insert(1, at: .root)
/// let left = try tree.insert(2, at: .left(of: root))
/// let right = try tree.insert(3, at: .right(of: root))
/// tree.forEachInOrder { print($0) }  // 2, 1, 3
/// ```
public struct NaryTree<Element: ~Copyable, let n: Int>: __TreeProtocol {

    /// Children are addressed by a type-safe bounded slot (`0..<n`).
    public typealias Address = __TreeNChildSlot<n>

    /// A bounded child slot index (`0..<n`).
    public typealias ChildSlot = __TreeNChildSlot<n>

    /// Typed node count (A3).
    public typealias Count = Index<Element>.Count

    /// A position (cursor) to a node.
    public typealias Position = __TreePosition

    /// The error type for the shared tree operations.
    public typealias Error = __TreeError

    /// The private generational arena (NON-PUBLIC — `@usableFromInline` for the
    /// inlinable witnesses; the `Tree.Protocol` defaults never reference it).
    @usableFromInline
    var _storage: TreeStorage<Element, InlineArray<n, Store.Generational.Handle?>>

    // MARK: Initialization (construction twins — the Copyable twin is in the extension below)

    /// Creates an empty tree (move-only elements).
    @inlinable
    public init() { _storage = TreeStorage() }

    /// Creates an empty tree with reserved capacity (move-only elements).
    @inlinable
    public init(minimumCapacity: Count) { _storage = TreeStorage(minimumCapacity: minimumCapacity) }

    // MARK: Properties

    /// The number of nodes in the tree (typed — A3).
    @inlinable
    public var count: Count { _storage.count }

    /// The maximum arity (children per node).
    @inlinable
    public static var arity: Int { n }

    // MARK: Arena requirements (delegated to the private TreeStorage)

    /// The root node's handle (the `Tree.Protocol` arena requirement).
    @inlinable
    public var _rootHandle: Store.Generational.Handle? {
        get { _storage.rootHandle }
        set { _storage.rootHandle = newValue }
    }

    /// Decodes a position to its live handle (the arena requirement).
    @inlinable
    public func _liveHandle(_ position: __TreePosition) -> Store.Generational.Handle? {
        _storage.liveHandle(position)
    }

    /// Inserts a childless node (all slots empty) with the given parent (the arena requirement).
    @inlinable
    public mutating func _insertNode(
        _ element: consuming Element,
        parent: Store.Generational.Handle?
    ) -> Store.Generational.Handle {
        _storage.insertNode(element, links: InlineArray<n, Store.Generational.Handle?>(repeating: nil), parent: parent)
    }

    /// Removes a node, moving its element out (the arena requirement).
    @inlinable
    public mutating func _removeNode(_ handle: Store.Generational.Handle) -> Element {
        _storage.removeNode(handle)
    }

    /// Removes every node and resets the root (the arena requirement).
    @inlinable
    public mutating func _removeAll() { _storage.removeAll() }

    /// The parent handle of a node (the arena requirement).
    @inlinable
    public func _parentHandle(of handle: Store.Generational.Handle) -> Store.Generational.Handle? {
        _storage.parentHandle(of: handle)
    }

    /// Borrowing access to a node's element (the arena requirement).
    @inlinable
    public func _withElement<R: ~Copyable>(
        at handle: Store.Generational.Handle,
        _ body: (borrowing Element) -> R
    ) -> R {
        _storage.withElement(at: handle, body)
    }

    // MARK: Child-link requirements (sparse fixed slots)

    /// The child handle at `slot`, or `nil` if the slot is empty.
    @inlinable
    public func _childHandle(
        at handle: Store.Generational.Handle,
        address slot: __TreeNChildSlot<n>
    ) -> Store.Generational.Handle? {
        _storage.withLinks(at: handle) { $0[slot.index] }
    }

    /// Rejects a slot that is already occupied (a bounded slot cannot be out of range).
    @inlinable
    public func _validateLink(
        to parent: Store.Generational.Handle,
        at slot: __TreeNChildSlot<n>
    ) throws(__TreeError) {
        let occupied = _storage.withLinks(at: parent) { $0[slot.index] != nil }
        guard !occupied else { throw .slotOccupied }
    }

    /// Sets the child handle at `slot` (precondition: validated empty).
    @inlinable
    public mutating func _linkChild(
        _ child: Store.Generational.Handle,
        to parent: Store.Generational.Handle,
        at slot: __TreeNChildSlot<n>
    ) {
        _storage.withLinksMut(at: parent) { $0[slot.index] = child }
    }

    /// Clears the slot holding `child` under `parent`.
    @inlinable
    public mutating func _unlinkChild(
        _ child: Store.Generational.Handle,
        from parent: Store.Generational.Handle
    ) {
        _storage.withLinksMut(at: parent) {
            for slot in 0..<n where $0[slot] == child {
                $0[slot] = nil
                return
            }
        }
    }

    /// The number of occupied child slots.
    @inlinable
    public func _childCount(at handle: Store.Generational.Handle) -> Int {
        _storage.withLinks(at: handle) {
            var occupied = 0
            for slot in 0..<n where $0[slot] != nil { occupied += 1 }
            return occupied
        }
    }

    /// Visits each occupied child handle in slot order.
    @inlinable
    public func _forEachChild(
        at handle: Store.Generational.Handle,
        _ body: (Store.Generational.Handle) -> Void
    ) {
        _storage.withLinks(at: handle) {
            for slot in 0..<n {
                if let child = $0[slot] { body(child) }
            }
        }
    }
}

// MARK: - Copyable construction twin (CoW; captures the clone strategy)

extension NaryTree: Copyable where Element: Copyable {
    /// Creates an empty CoW tree (the clone strategy is captured via the
    /// `TreeStorage` Copyable twin).
    @inlinable
    public init() { _storage = TreeStorage() }

    /// Creates an empty CoW tree with reserved capacity.
    @inlinable
    public init(minimumCapacity: Count) { _storage = TreeStorage(minimumCapacity: minimumCapacity) }
}

// MARK: - The tree abstraction alias (the Array.Protocol pattern)

extension NaryTree {
    /// The tree abstraction — the canonical surfacing of ``__TreeProtocol``.
    public typealias `Protocol` = __TreeProtocol
}

// MARK: - Sendable

extension NaryTree: @unsafe @unchecked Sendable where Element: Sendable {}
