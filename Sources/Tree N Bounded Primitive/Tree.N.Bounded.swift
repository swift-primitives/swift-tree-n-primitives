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

public import Column_Primitives
public import Shared_Primitive
public import Storage_Generational_Primitives
public import Store_Primitive
public import Buffer_Ring_Primitive
public import Queue_Primitives
public import Stack_Primitives

// MARK: - Bounded N-ary Tree

extension Tree.N where Element: ~Copyable {

    /// A fixed-capacity n-ary tree.
    ///
    /// `N.Bounded` allocates storage upfront and throws on overflow.
    /// Use this variant when capacity is known or in contexts requiring
    /// predictable memory behavior (embedded, real-time).
    ///
    /// The node column never grows: insertion at full capacity throws
    /// ``Bounded/Error/overflow`` from a `count == capacity` pre-check (the
    /// column's exhaustion trap is unreachable).
    ///
    /// ## Example
    ///
    /// ```swift
    /// var tree = try Tree<Int>.N<2>.Bounded(capacity: 100)
    /// let root = try tree.insert(1, at: .root)
    /// let left = try tree.insert(2, at: .left(of: root))
    /// ```
    // WHY: Category D — structural Sendable workaround; the type is
    // WHY: structurally value-safe but the compiler cannot synthesize
    // WHY: Sendable due to a stored pointer / generic parameter shape.
    @safe
    public struct Bounded: ~Copyable {

        // MARK: - Typealiases

        /// Errors that can occur during bounded n-ary tree operations.
        public typealias Error = __TreeNBoundedError

        /// Node type from parent Tree.N.
        public typealias Node = Tree.N<n>.Node

        /// Typed node count.
        public typealias Count = Index<Node>.Count

        // MARK: - Storage

        /// The node column: the generational slot store behind the `Shared` CoW box
        /// (fixed slot universe — no growth door is ever called).
        @usableFromInline
        var _storage: Shared<Node, Column.Generational<Node>>

        /// Handle of root node (nil if empty).
        @usableFromInline
        var _rootHandle: Store.Generational.Handle?

        /// The maximum number of nodes the tree can hold.
        public let capacity: Count

        // MARK: - Initialization
        //
        // The construction twins split on element copyability via MEMBER-LEVEL
        // where-clauses (SE-0267) — see `Tree.N`'s initializer note.

        /// Creates a tree with the specified capacity (move-only elements).
        ///
        /// - Parameter capacity: Maximum number of nodes.
        @inlinable
        public init(capacity: Count) {
            self.capacity = capacity
            let slots = Index<Node>.Count(UInt(Swift.max(Int(bitPattern: capacity), 1)))
            self._storage = Shared(Column.Generational<Node>.create(slotCapacity: slots))
            self._rootHandle = nil
        }

        /// Creates a tree with the specified capacity (CoW-capable column; the
        /// clone strategy is captured here — the Copyable construction twin).
        ///
        /// - Parameter capacity: Maximum number of nodes.
        @inlinable
        public init(capacity: Count) where Element: Copyable {
            self.capacity = capacity
            let slots = Index<Node>.Count(UInt(Swift.max(Int(bitPattern: capacity), 1)))
            self._storage = Shared(Column.Generational<Node>.create(slotCapacity: slots))
            self._rootHandle = nil
        }

        // MARK: - Properties

        /// The number of nodes in the tree.
        @inlinable
        public var count: Count { _storage.withColumn { $0.count } }

        /// Whether the tree is empty.
        @inlinable
        public var isEmpty: Bool { _storage.withColumn { $0.isEmpty } }

        /// Whether the tree is full.
        @inlinable
        public var isFull: Bool { count == capacity }

        /// The position of the root node, or `nil` if the tree is empty.
        @inlinable
        public var root: Tree.Position? {
            guard let rootHandle = _rootHandle else { return nil }
            return _position(of: rootHandle)
        }

        // MARK: - Handle Plumbing

        /// Mints the public position for a live handle (the slot generation
        /// projected into the `UInt32` token; wraps after 2^32 frees of one slot).
        @inlinable
        func _position(of handle: Store.Generational.Handle) -> Tree.Position {
            Tree.Position(index: handle.index, token: UInt32(truncatingIfNeeded: handle.generation))
        }

        /// Decodes a public position by RECONSTRUCTING the live handle from the
        /// column's ledger (`handle(at:)` — Round M B2; no side table).
        @usableFromInline
        func _handle(_ position: Tree.Position) throws(__TreeNBoundedError) -> Store.Generational.Handle {
            let slot = Int(bitPattern: position.index)
            guard
                slot >= 0,
                let handle = _storage.withColumn({ $0.handle(at: Index<Node>(Ordinal(UInt(slot)))) }),
                UInt32(truncatingIfNeeded: handle.generation) == position.token
            else { throw .invalidPosition }
            return handle
        }

        /// Validates that a position refers to a currently-occupied slot.
        @usableFromInline
        func _validate(_ position: Tree.Position) throws(__TreeNBoundedError) {
            _ = try _handle(position)
        }

        /// Inserts a node into the fixed column (callers pre-check fullness).
        @inlinable
        mutating func _insert(node: consuming Node) -> Store.Generational.Handle {
            _storage.withUnique(consuming: node) { (column, node) in
                column.insert(node)
            }
        }

        /// Removes the node at a live handle.
        @inlinable
        mutating func _remove(_ handle: Store.Generational.Handle) -> Node {
            guard let node = _storage.withUnique({ $0.remove(handle) }) else {
                // Unreachable: callers pass decoded live handles and no removal interleaves.
                preconditionFailure("Tree.N.Bounded: live handle failed to resolve on removal")
            }
            return node
        }

        /// Detaches the child link `handle` from its parent's sparse slots (or
        /// clears the root) and decrements the parent's child count.
        @inlinable
        mutating func _unlink(_ handle: Store.Generational.Handle) {
            guard let parentHandle = _storage.withColumn({ $0[handle].parentHandle }) else {
                // This is the root
                _rootHandle = nil
                return
            }
            _storage.withUnique { column in
                for slot in 0..<n {
                    if column[parentHandle].childHandles[slot] == handle {
                        column[parentHandle].childHandles[slot] = nil
                        column[parentHandle].childCount = column[parentHandle].childCount.subtract.saturating(.one)
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Navigation

extension Tree.N.Bounded where Element: ~Copyable {

    /// Returns the position of the child at the given slot.
    @inlinable
    public func child(of position: Tree.Position, slot: Tree.N<n>.ChildSlot) -> Tree.Position? {
        guard let handle = try? _handle(position) else { return nil }
        guard let child = _storage.withColumn({ $0[handle].childHandles[slot.index] }) else { return nil }
        return _position(of: child)
    }

    /// Returns the position of the parent of the node at the given position.
    @inlinable
    public func parent(of position: Tree.Position) -> Tree.Position? {
        guard let handle = try? _handle(position) else { return nil }
        guard let parentHandle = _storage.withColumn({ $0[handle].parentHandle }) else {
            return nil
        }
        return _position(of: parentHandle)
    }

    /// Returns whether the node at the given position is a leaf.
    @inlinable
    public func isLeaf(_ position: Tree.Position) -> Bool {
        guard let handle = try? _handle(position) else { return false }
        return _storage.withColumn { $0[handle].childCount == .zero }
    }

    /// Returns the number of children of the node at the given position.
    @inlinable
    public func childCount(of position: Tree.Position) -> Count? {
        guard let handle = try? _handle(position) else { return nil }
        return _storage.withColumn { $0[handle].childCount }
    }
}

// MARK: - Binary Tree Navigation Convenience (n == 2)

extension Tree.N.Bounded where Element: ~Copyable, n == 2 {

    /// Returns the position of the left child.
    @inlinable
    public func left(of position: Tree.Position) -> Tree.Position? {
        child(of: position, slot: .left)
    }

    /// Returns the position of the right child.
    @inlinable
    public func right(of position: Tree.Position) -> Tree.Position? {
        child(of: position, slot: .right)
    }
}

// MARK: - Insert Operations (~Copyable)

extension Tree.N.Bounded where Element: ~Copyable {

    /// Inserts an element at the specified position.
    @inlinable
    @discardableResult
    public mutating func insert(
        _ element: consuming Element,
        at position: Tree.N<n>.InsertPosition
    ) throws(__TreeNBoundedError) -> Tree.Position {
        switch position {
        case .root:
            guard _rootHandle == nil else {
                throw .slotOccupied
            }
            guard !isFull else {
                throw .overflow
            }
            let handle = _insert(node: Node(element: element))
            _rootHandle = handle
            return _position(of: handle)

        case .child(of: let parent, let slot):
            let parentHandle = try _handle(parent)
            guard _storage.withColumn({ $0[parentHandle].childHandles[slot.index] == nil }) else {
                throw .slotOccupied
            }
            guard !isFull else {
                throw .overflow
            }
            let handle = _insert(node: Node(element: element, parentHandle: parentHandle))
            _storage.withUnique { column in
                column[parentHandle].childHandles[slot.index] = handle
                column[parentHandle].childCount += .one
            }
            return _position(of: handle)
        }
    }

    /// Removes the leaf node at the specified position.
    @inlinable
    @discardableResult
    public mutating func remove(at position: Tree.Position) throws(__TreeNBoundedError) -> Element {
        let handle = try _handle(position)

        guard _storage.withColumn({ $0[handle].childCount == .zero }) else {
            throw .cannotRemoveNonLeaf
        }

        _unlink(handle)

        let node = _remove(handle)
        return node.element
    }

    /// Removes the subtree rooted at the specified position.
    @inlinable
    public mutating func removeSubtree(at position: Tree.Position) throws(__TreeNBoundedError) {
        let handle = try _handle(position)

        _unlink(handle)

        var pending = Stack<Store.Generational.Handle>()
        var lastVisited: Store.Generational.Handle? = nil

        pending.push(handle)

        while !pending.isEmpty {
            let current = pending.peek { $0 }!
            let childHandles = _storage.withColumn { $0[current].childHandles }

            var rightmostChild: Store.Generational.Handle? = nil
            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    rightmostChild = child
                    break
                }
            }

            var leftmostChild: Store.Generational.Handle? = nil
            for slot in 0..<n {
                if let child = childHandles[slot] {
                    leftmostChild = child
                    break
                }
            }

            let isLeaf = rightmostChild == nil
            let cameFromRightmost = rightmostChild != nil && rightmostChild == lastVisited
            let cameFromLeftmostNoOther = leftmostChild != nil && leftmostChild == lastVisited && leftmostChild == rightmostChild

            if isLeaf || cameFromRightmost || cameFromLeftmostNoOther {
                _ = pending.pop()
                _ = _remove(current)
                lastVisited = current
            } else {
                for slot in stride(from: n - 1, through: 0, by: -1) {
                    if let child = childHandles[slot] {
                        pending.push(child)
                    }
                }
            }
        }
    }

    /// Accesses the element at the specified position via a borrowing closure.
    @inlinable
    public func peek<R>(at position: Tree.Position, _ body: (borrowing Element) -> R) -> R? {
        guard let handle = try? _handle(position) else { return nil }
        return _storage.withColumn { body($0[handle].element) }
    }

    /// Clears all nodes from the tree.
    @inlinable
    public mutating func clear() {
        _storage.withUnique { $0.removeAll() }
        _rootHandle = nil
    }

    /// Computes the height of the tree.
    ///
    /// An empty tree returns `nil`, a single-node tree has height `.zero`.
    @inlinable
    public var height: Count? {
        guard let rootHandle = _rootHandle else { return nil }

        var maxHeight: Count = .zero
        var pending = Stack<(handle: Store.Generational.Handle, depth: Count)>()
        pending.push((rootHandle, .zero))

        while !pending.isEmpty {
            let (handle, depth) = pending.pop()!
            maxHeight = Swift.max(maxHeight, depth)

            let childHandles = _storage.withColumn { $0[handle].childHandles }
            for slot in 0..<n {
                if let child = childHandles[slot] {
                    pending.push((child, depth + .one))
                }
            }
        }

        return maxHeight
    }
}

// MARK: - Traversal

extension Tree.N.Bounded where Element: ~Copyable {

    /// Iterates over all elements in pre-order.
    @inlinable
    public func forEachPreOrder(_ body: (borrowing Element) -> Void) {
        guard let rootHandle = _rootHandle else { return }
        var pending = Stack<Store.Generational.Handle>()
        pending.push(rootHandle)

        while !pending.isEmpty {
            let handle = pending.pop()!
            let childHandles = _storage.withColumn {
                (column) -> InlineArray<n, Store.Generational.Handle?> in
                body(column[handle].element)
                return column[handle].childHandles
            }

            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    pending.push(child)
                }
            }
        }
    }

    /// Iterates over all elements in post-order.
    @inlinable
    public func forEachPostOrder(_ body: (borrowing Element) -> Void) {
        guard let rootHandle = _rootHandle else { return }
        var pending = Stack<Store.Generational.Handle>()
        var lastVisited: Store.Generational.Handle? = nil
        pending.push(rootHandle)

        while !pending.isEmpty {
            let current = pending.peek { $0 }!
            let childHandles = _storage.withColumn { $0[current].childHandles }

            var rightmostChild: Store.Generational.Handle? = nil
            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    rightmostChild = child
                    break
                }
            }

            var leftmostChild: Store.Generational.Handle? = nil
            for slot in 0..<n {
                if let child = childHandles[slot] {
                    leftmostChild = child
                    break
                }
            }

            let isLeaf = rightmostChild == nil
            let cameFromRightmost = rightmostChild != nil && rightmostChild == lastVisited
            let cameFromLeftmostNoOther = leftmostChild != nil && leftmostChild == lastVisited && leftmostChild == rightmostChild

            if isLeaf || cameFromRightmost || cameFromLeftmostNoOther {
                _ = pending.pop()
                _storage.withColumn { body($0[current].element) }
                lastVisited = current
            } else {
                for slot in stride(from: n - 1, through: 0, by: -1) {
                    if let child = childHandles[slot] {
                        pending.push(child)
                    }
                }
            }
        }
    }

    /// Iterates over all elements in level-order.
    @inlinable
    public func forEachLevelOrder(_ body: (borrowing Element) -> Void) {
        guard let rootHandle = _rootHandle else { return }

        var pending = Queue<Column.Ring<Store.Generational.Handle>>()
        pending.enqueue(rootHandle)

        while !pending.isEmpty {
            let handle = pending.dequeue()!

            let childHandles = _storage.withColumn {
                (column) -> InlineArray<n, Store.Generational.Handle?> in
                body(column[handle].element)
                return column[handle].childHandles
            }
            for slot in 0..<n {
                if let child = childHandles[slot] {
                    pending.enqueue(child)
                }
            }
        }
    }
}

// MARK: - Binary Tree In-Order Traversal (n == 2)

extension Tree.N.Bounded where Element: ~Copyable, n == 2 {

    /// Iterates over all elements in in-order.
    @inlinable
    public func forEachInOrder(_ body: (borrowing Element) -> Void) {
        guard let rootHandle = _rootHandle else { return }
        var pending = Stack<Store.Generational.Handle>()
        var current: Store.Generational.Handle? = rootHandle

        while current != nil || !pending.isEmpty {
            while let c = current {
                pending.push(c)
                current = _storage.withColumn { $0[c].childHandles[0] }
            }

            let c = pending.pop()!
            current = _storage.withColumn { (column) -> Store.Generational.Handle? in
                body(column[c].element)
                return column[c].childHandles[1]
            }
        }
    }
}

// MARK: - Copyable Element Extensions

extension Tree.N.Bounded where Element: Copyable {

    /// Inserts an element at the specified position (CoW-aware).
    ///
    /// Uniqueness is restored by the `withUnique` gate inside each storage
    /// mutation, so a tree sharing its column with a copy detaches before writing.
    @inlinable
    @discardableResult
    public mutating func insert(
        _ element: Element,
        at position: Tree.N<n>.InsertPosition
    ) throws(__TreeNBoundedError) -> Tree.Position {
        switch position {
        case .root:
            guard _rootHandle == nil else {
                throw .slotOccupied
            }
            guard !isFull else {
                throw .overflow
            }
            let handle = _insert(node: Node(element: element))
            _rootHandle = handle
            return _position(of: handle)

        case .child(of: let parent, let slot):
            let parentHandle = try _handle(parent)
            guard _storage.withColumn({ $0[parentHandle].childHandles[slot.index] == nil }) else {
                throw .slotOccupied
            }
            guard !isFull else {
                throw .overflow
            }
            let handle = _insert(node: Node(element: element, parentHandle: parentHandle))
            _storage.withUnique { column in
                column[parentHandle].childHandles[slot.index] = handle
                column[parentHandle].childCount += .one
            }
            return _position(of: handle)
        }
    }

    /// Returns the element at the specified position.
    @inlinable
    public func peek(at position: Tree.Position) -> Element? {
        guard let handle = try? _handle(position) else { return nil }
        return _storage.withColumn { $0[handle].element }
    }
}

// MARK: - Traversal Sequences (Copyable elements only)

extension Tree.N.Bounded where Element: Copyable {

    /// A sequence that yields elements in pre-order.
    public var preOrder: Order.Pre.Sequence {
        Order.Pre.Sequence(tree: self)
    }

    /// A sequence that yields elements in post-order.
    public var postOrder: Order.Post.Sequence {
        Order.Post.Sequence(tree: self)
    }

    /// A sequence that yields elements in level-order.
    public var levelOrder: Order.Level.Sequence {
        Order.Level.Sequence(tree: self)
    }
}

// MARK: - Binary Tree In-Order Sequence (n == 2)

extension Tree.N.Bounded where Element: Copyable, n == 2 {

    /// A sequence that yields elements in in-order.
    public var inOrder: Order.In.Sequence {
        Order.In.Sequence(tree: self)
    }
}

// MARK: - Conditional Copyable

extension Tree.N.Bounded: Copyable where Element: Copyable {}

// MARK: - Sendable

extension Tree.N.Bounded: @unsafe @unchecked Sendable where Element: Sendable {}
