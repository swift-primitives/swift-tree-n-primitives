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

public import Stack_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension Tree where Element: ~Copyable {

    // Conforms to the hoisted `__TreeProtocol` (the `Tree.Protocol` surfacing): the
    // `.Protocol` typealias spelling collides with the metatype keyword in a
    // conformance clause, so the hoisted name is named directly here (as `Tree` does).
    /// A dynamically-growing n-ary tree with compile-time bounded arity.
    ///
    /// `Tree.N<n>` is the general-purpose bounded-arity tree primitive: each node may
    /// have at most `n` children, addressed by a bounded ``ChildSlot`` (`0..<n`). Child
    /// slots are sparse — holes are permitted; inserting into an occupied slot fails
    /// with ``Error/slotOccupied``.
    ///
    /// It is the bounded-arity ``Tree/Protocol`` conformer: the generational arena,
    /// decode (Round M B2), token validation, typed counts (A3), the
    /// position-survives-growth contract, and the shared insert / remove / navigation /
    /// traversal algorithms live in ``Tree/Storage`` + the ``Tree/Protocol`` defaults.
    /// This type supplies the sparse `InlineArray<n, Handle?>` child-link representation
    /// and its six link witnesses; the binary `left`/`right` ride the shared `child`
    /// navigation, and in-order traversal is the `forEach.inOrder` accessor.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Binary tree (n=2)
    /// var tree = Tree<Int>.N<2>()
    /// let root = try tree.insert(1, at: .root)
    /// let left = try tree.insert(2, at: .left(of: root))
    /// let right = try tree.insert(3, at: .right(of: root))
    ///
    /// tree.forEachInOrder { element in
    ///     print(element)  // 2, 1, 3
    /// }
    ///
    /// // Quad tree (n=4)
    /// var quad = Tree<Int>.N<4>()
    /// let qroot = try quad.insert(0, at: .root)
    /// _ = try quad.insert(1, at: .northwest(of: qroot))
    /// _ = try quad.insert(2, at: .southeast(of: qroot))
    /// ```
    ///
    /// ## Sparse Child Slots
    ///
    /// Per [TREE-003], `Tree<Element>.N<n>` uses sparse child slots: each node stores
    /// `InlineArray<n, Handle?>` where `nil` denotes an empty slot. Holes are permitted.
    ///
    /// ## Move-Only Support
    ///
    /// Both the tree and its elements may be `~Copyable`:
    ///
    /// ```swift
    /// struct FileHandle: ~Copyable { ... }
    /// var handles = Tree<FileHandle>.N<2>()
    /// let root = try handles.insert(FileHandle(), at: .root)
    /// ```
    ///
    /// ## Copy-on-Write
    ///
    /// When `Element` is `Copyable`, `Tree.N` is copy-on-write: copies share the
    /// generational column behind the `Shared` CoW box until mutation. The clone
    /// strategy is the GENERATION-PRESERVING deep copy, so a position minted before a
    /// CoW detach keeps resolving on both sides of the split.
    ///
    /// - Note: Declared in an extension. Swift 6.2.4 resolved the value-generic
    ///   nested type extension restriction ([COPY-FIX-002]).
    public struct N<let n: Int>: ~Copyable, __TreeProtocol {

        // MARK: - Typealiases

        /// How a child is addressed within its parent: a bounded slot index (`0..<n`).
        public typealias Address = __TreeNChildSlot<n>

        /// A bounded child slot index (`0..<n`).
        public typealias ChildSlot = __TreeNChildSlot<n>

        /// The error type for the shared tree operations.
        public typealias Error = __TreeError

        /// Typed node count (A3).
        public typealias Count = Index<Element>.Count

        // MARK: - Storage

        /// The private generational arena.
        ///
        /// NON-PUBLIC — `@usableFromInline` for the inlinable witnesses; the
        /// `Tree.Protocol` defaults never reference it. The sparse child links are the
        /// per-conformer `InlineArray<n, Handle?>` (holes permitted).
        @usableFromInline
        var _storage: Storage<InlineArray<n, Store.Generational.Handle?>>

        // MARK: - Initialization (MEMBER-LEVEL construction twins)
        //
        // The twins split on element copyability via MEMBER-LEVEL where-clauses
        // (SE-0267): the `Copyable` twin captures the column's generation-preserving
        // clone strategy via the `Tree.Storage` Copyable twin; the `~Copyable` twin
        // captures none. EXTENSION-level twins are NOT usable here — on a
        // nested-in-extension inverse-generic type the extension signature
        // canonicalizes the Copyable requirement away and both inits mangle
        // identically (the re-validation finding). At `Copyable` call sites the
        // more-constrained twin wins.

        /// Creates an empty n-ary tree (move-only elements).
        @inlinable
        public init() { _storage = Storage<InlineArray<n, Store.Generational.Handle?>>() }

        /// Creates an empty n-ary tree with reserved capacity (move-only elements).
        @inlinable
        public init(minimumCapacity: Count) {
            _storage = Storage<InlineArray<n, Store.Generational.Handle?>>(minimumCapacity: minimumCapacity)
        }

        /// Creates an empty CoW-capable n-ary tree (the clone strategy is captured here).
        @inlinable
        public init() where Element: Copyable {
            _storage = Storage<InlineArray<n, Store.Generational.Handle?>>()
        }

        /// Creates an empty CoW-capable n-ary tree with reserved capacity.
        @inlinable
        public init(minimumCapacity: Count) where Element: Copyable {
            _storage = Storage<InlineArray<n, Store.Generational.Handle?>>(minimumCapacity: minimumCapacity)
        }

        // MARK: - Properties

        /// The maximum arity (number of children per node).
        @inlinable
        public static var arity: Int { n }

        /// The number of nodes in the tree (typed — A3).
        @inlinable
        public var count: Count { _storage.count }

        // The per-node child count is the shared `tree.child.count(of:)` view member
        // (R1 W4 [API-NAME-002]; tree-core `__TreeChild.swift`) — `Int?`, matching the
        // bounded-slot tally; the compound `childCount(of:)` was folded into `child`.

        // MARK: - Arena requirements (delegated to the private Tree.Storage)

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

        /// Inserts a childless node (all-`nil` sparse links) with the given parent.
        @inlinable
        public mutating func _insertNode(
            _ element: consuming Element,
            parent: Store.Generational.Handle?
        ) -> Store.Generational.Handle {
            _storage.insertNode(
                element,
                links: InlineArray<n, Store.Generational.Handle?>(repeating: nil),
                parent: parent
            )
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

        // MARK: - Child-link requirements (sparse InlineArray<n, Handle?>)

        /// The child handle at a bounded slot, or `nil` if the slot is empty.
        @inlinable
        public func _childHandle(
            at handle: Store.Generational.Handle,
            address: __TreeNChildSlot<n>
        ) -> Store.Generational.Handle? {
            _storage.withLinks(at: handle) { $0[address.index] }
        }

        /// Rejects a child link into an occupied slot (the per-conformer error precision).
        @inlinable
        public func _validateLink(
            to parent: Store.Generational.Handle,
            at address: __TreeNChildSlot<n>
        ) throws(__TreeError) {
            let occupied = _storage.withLinks(at: parent) { $0[address.index] != nil }
            if occupied { throw .slotOccupied }
        }

        /// Links a child handle into a bounded slot (precondition: validated).
        @inlinable
        public mutating func _linkChild(
            _ child: Store.Generational.Handle,
            to parent: Store.Generational.Handle,
            at address: __TreeNChildSlot<n>
        ) {
            _storage.withLinksMut(at: parent) { $0[address.index] = child }
        }

        /// Clears the sparse slot holding `child` under `parent`.
        @inlinable
        public mutating func _unlinkChild(
            _ child: Store.Generational.Handle,
            from parent: Store.Generational.Handle
        ) {
            _storage.withLinksMut(at: parent) { links in
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
            _storage.withLinks(at: handle) { links in
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
            _storage.withLinks(at: handle) { links in
                for slot in 0..<n {
                    if let child = links[slot] { body(child) }
                }
            }
        }
    }
}

// MARK: - Binary Tree Navigation Convenience (n == 2; over the shared `child(of:at:)`)

extension Tree.N where Element: ~Copyable, n == 2 {

    /// The position of the left child, or `nil` if there is no left child / the
    /// position is invalid.
    @inlinable
    public func left(of position: Tree.Position) -> Tree.Position? {
        _child(of: position, at: .left)
    }

    /// The position of the right child, or `nil` if there is no right child / the
    /// position is invalid.
    @inlinable
    public func right(of position: Tree.Position) -> Tree.Position? {
        _child(of: position, at: .right)
    }
}

// MARK: - Folded into fluent accessors (R1 W4 [API-NAME-002])
//
// `leftmostChild` / `rightmostChild` → the shared `tree.child.leftmost(of:)` /
// `.rightmost(of:)` view members (tree-core `__TreeChild.swift`, generalized to
// first/last child of any ordered tree). `forEachInOrder` → `tree.forEach.inOrder { }`
// (binary only) in `Tree.N.ForEach.swift`.

// MARK: - Conditional Copyable (CoW; rides the `Tree.Storage` Copyable twin)

extension Tree.N: Copyable where Element: Copyable {}

// MARK: - Sendable
//
// PROPER conditional Sendable (no `@unchecked`, no `@unsafe`): it rides the arena's
// Sendable chain — `Tree.Storage` is `Sendable where Element, ChildLinks: Sendable`;
// the sparse `InlineArray<n, Handle?>` links are `Sendable` (the handle is always
// `Sendable`), so the conformance carries on `Element: Sendable` alone.

extension Tree.N: Sendable where Element: Sendable {}
