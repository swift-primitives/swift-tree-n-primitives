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

/// A dynamically-growing n-ary tree with compile-time bounded arity.
///
/// `Tree.N<n>` is the general-purpose bounded-arity tree primitive. It provides O(1)
/// node insertion and O(1) navigation with automatic capacity growth. Each node can
/// have at most `n` children, with child slots being sparse (holes permitted).
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
/// Per [TREE-003], `Tree<Element>.N<n>` uses sparse child slots. Each node
/// stores `childHandles[0..<n]` where `nil` denotes empty. Holes are permitted.
/// Insertion into an occupied slot fails with `.slotOccupied` error.
///
/// ## Variants
///
/// - ``N``: Dynamically-growing with amortized O(1) insert (this type)
/// - ``N/Bounded``: Fixed-capacity with upfront allocation, throws on overflow
/// - ``N/Inline``: Zero-allocation inline storage with compile-time capacity
/// - ``N/Small``: Inline storage with automatic spill to heap
///
/// ## Move-Only Support
///
/// Both the tree and its elements can be `~Copyable`:
///
/// ```swift
/// struct FileHandle: ~Copyable { ... }
/// var handles = Tree<FileHandle>.N<2>()
/// let root = try handles.insert(FileHandle(), at: .root)
/// ```
///
/// ## Copy-on-Write
///
/// When `Element` is `Copyable`, `Tree.N` uses copy-on-write semantics:
/// copies share storage until mutation, providing efficient value semantics.
/// The CoW machinery is the ratified `Shared` column (the W5 tower design): the
/// stored generational column rides a refcounted box whose uniqueness gate
/// (`withUnique`) runs before every mutation, and whose clone strategy is the
/// GENERATION-PRESERVING deep copy — positions minted before a CoW detach keep
/// resolving on both sides of the split.
///
/// ## Generational Column Storage
///
/// Uses `Shared<Node, Column.Generational<Node>>` for storage — nodes live in a
/// sparse handle-validated slot column (`Storage.Generational`) with per-slot
/// generation tokens and free-slot recycling. Nodes reference each other by
/// generational `Handle` rather than pointer. Growth is explicit: when the column
/// is full the tree calls the generation-preserving relocating door (`grow(to:)`),
/// which retires the old pool wholesale and continues the incarnation history
/// index-aligned — outstanding positions survive growth.
///
/// Public `Tree.Position` tokens project the slot's generation into `UInt32`
/// (`UInt32(truncatingIfNeeded:)`): a token wraps after 2^32 frees of one slot
/// — equivalent to the retired arena's UInt32 token wrap.
///
/// - Note: Declared in an extension. Swift 6.2.4 resolved the value-generic
///   nested type extension restriction ([COPY-FIX-002]).
extension Tree where Element: ~Copyable {

    // WHY: Category D — structural Sendable workaround; the type is
    // WHY: structurally value-safe but the compiler cannot synthesize
    // WHY: Sendable due to a stored pointer / generic parameter shape.
    @safe
    public struct N<let n: Int>: ~Copyable {

        // MARK: - Typealiases

        /// Errors that can occur during n-ary tree operations.
        public typealias Error = __TreeNError

        /// A bounded child slot index (0..<n).
        public typealias ChildSlot = __TreeNChildSlot<n>

        /// Specifies where to insert a new node.
        public typealias InsertPosition = __TreeNInsertPosition<n>

        /// Typed node count.
        public typealias Count = Index<Node>.Count

        // MARK: - Node

        /// A node in the generational-column n-ary tree.
        @frozen
        public struct Node: ~Copyable {
            /// The element stored in this node.
            public var element: Element
            /// Child handles (nil for empty slots). Uses sparse representation per [TREE-003].
            public var childHandles: InlineArray<n, Store.Generational.Handle?>
            /// Number of occupied child slots.
            public var childCount: Count
            /// Handle of parent (nil for root).
            public var parentHandle: Store.Generational.Handle?

            @inlinable
            public init(element: consuming Element, parentHandle: Store.Generational.Handle? = nil) {
                self.element = element
                self.childHandles = InlineArray(repeating: nil)
                self.childCount = .zero
                self.parentHandle = parentHandle
            }
        }

        // MARK: - Storage

        /// The node column: the generational slot store behind the `Shared` CoW box.
        /// Copyability flows from the column (`Shared<Node, B>` is `Copyable` iff
        /// `Node` is, and `Node` iff `Element`) — the S5 chain.
        @usableFromInline
        var _storage: Shared<Node, Column.Generational<Node>>

        /// Slot → live handle side table for decoding public `Tree.Position` values
        /// (a position carries only `(slot, UInt32 token)`; handles cannot be minted
        /// outside the column, so the tree records the handle of every occupied slot).
        /// Sized to the column's capacity; `nil` marks a free slot.
        @usableFromInline
        var _handles: Swift.Array<Store.Generational.Handle?>

        /// Handle of root node (nil if empty).
        @usableFromInline
        var _rootHandle: Store.Generational.Handle?

        // MARK: - Initialization
        //
        // The construction twins split on element copyability via MEMBER-LEVEL
        // where-clauses (SE-0267): `Shared`'s constructors split on element
        // copyability — the `Copyable` twin captures the column's
        // generation-preserving clone strategy so a shared box can restore
        // uniqueness; the `~Copyable` twin captures none. EXTENSION-level twins
        // are NOT usable here: on a nested-in-extension inverse-generic type the
        // extension signature canonicalizes the Copyable requirement away and
        // both inits mangle identically. At `Copyable` call sites the
        // more-constrained twin wins.

        /// Creates an empty n-ary tree (move-only elements).
        @inlinable
        public init() {
            self._storage = Shared(Column.Generational<Node>.create(slotCapacity: 1))
            self._handles = Swift.Array(repeating: nil, count: 1)
            self._rootHandle = nil
        }

        /// Creates an empty n-ary tree with reserved capacity (move-only elements).
        ///
        /// - Parameter minimumCapacity: The minimum number of nodes to reserve space for.
        @inlinable
        public init(minimumCapacity: Count) {
            let capacity = Swift.max(Int(bitPattern: minimumCapacity), 1)
            self._storage = Shared(Column.Generational<Node>.create(slotCapacity: capacity))
            self._handles = Swift.Array(repeating: nil, count: capacity)
            self._rootHandle = nil
        }

        /// Creates an empty n-ary tree (CoW-capable column; the clone strategy
        /// is captured here — the Copyable construction twin).
        @inlinable
        public init() where Element: Copyable {
            self._storage = Shared(Column.Generational<Node>.create(slotCapacity: 1))
            self._handles = Swift.Array(repeating: nil, count: 1)
            self._rootHandle = nil
        }

        /// Creates an empty n-ary tree with reserved capacity (CoW-capable
        /// column; the clone strategy is captured here — the Copyable construction twin).
        ///
        /// - Parameter minimumCapacity: The minimum number of nodes to reserve space for.
        @inlinable
        public init(minimumCapacity: Count) where Element: Copyable {
            let capacity = Swift.max(Int(bitPattern: minimumCapacity), 1)
            self._storage = Shared(Column.Generational<Node>.create(slotCapacity: capacity))
            self._handles = Swift.Array(repeating: nil, count: capacity)
            self._rootHandle = nil
        }

        // MARK: - Properties

        /// The number of nodes in the tree.
        @inlinable
        public var count: Count { _storage.withColumn { $0.count } }

        /// Whether the tree is empty.
        @inlinable
        public var isEmpty: Bool { _storage.withColumn { $0.isEmpty } }

        /// The maximum arity (number of children per node).
        @inlinable
        public static var arity: Int { n }

        /// The position of the root node, or `nil` if the tree is empty.
        @inlinable
        public var root: Tree.Position? {
            guard let rootHandle = _rootHandle else { return nil }
            return _position(of: rootHandle)
        }

        // MARK: - Handle Plumbing

        /// Mints the public position for a live handle: the slot plus the slot
        /// generation projected into the position's `UInt32` token (wraps after
        /// 2^32 frees of one slot — the retired arena's wrap, unchanged).
        @inlinable
        func _position(of handle: Store.Generational.Handle) -> Tree.Position {
            Tree.Position(index: handle.index, token: UInt32(truncatingIfNeeded: handle.generation))
        }

        /// Decodes a public position into the live handle for its slot.
        ///
        /// Token validation provides O(1) safety checking:
        /// - Stale positions (after removal) are detected and rejected
        /// - No node memory is accessed without validation
        @usableFromInline
        func _handle(_ position: Tree.Position) throws(__TreeNError) -> Store.Generational.Handle {
            let slot = Int(bitPattern: position.index)
            guard
                slot >= 0,
                slot < _handles.count,
                let handle = _handles[slot],
                UInt32(truncatingIfNeeded: handle.generation) == position.token,
                _storage.withColumn({ $0.contains(handle) })
            else { throw .invalidPosition }
            return handle
        }

        /// Validates that a position refers to a currently-occupied slot.
        @usableFromInline
        func _validate(_ position: Tree.Position) throws(__TreeNError) {
            _ = try _handle(position)
        }

        /// Inserts a node into the column, growing first when full (the explicit
        /// `grow(to:)` door — positions survive growth by its contract), and
        /// records the minted handle in the side table.
        @inlinable
        mutating func _insert(node: consuming Node) -> Store.Generational.Handle {
            let handle = _storage.withUnique(consuming: node) { (column, node) -> Store.Generational.Handle in
                if column.count == column.capacity {
                    let doubled = Index<Node>.Count(UInt(2 &* Int(bitPattern: column.capacity)))
                    column.grow(to: doubled)
                }
                return column.insert(node)
            }
            let capacity = Int(bitPattern: _storage.capacity)
            while _handles.count < capacity {
                _handles.append(nil)
            }
            _handles[handle.index] = handle
            return handle
        }

        /// Removes the node at a live handle, clearing its side-table entry.
        @inlinable
        mutating func _remove(_ handle: Store.Generational.Handle) -> Node {
            guard let node = _storage.withUnique({ $0.remove(handle) }) else {
                // Unreachable: callers pass decoded live handles and no removal interleaves.
                preconditionFailure("Tree.N: live handle failed to resolve on removal")
            }
            _handles[handle.index] = nil
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

extension Tree.N where Element: ~Copyable {

    /// Returns the position of the child at the given slot.
    ///
    /// - Parameters:
    ///   - position: The position of the parent node.
    ///   - slot: The child slot (0..<n).
    /// - Returns: The position of the child, or `nil` if the slot is empty.
    /// - Note: Returns `nil` if the position is invalid (stale or out of bounds).
    @inlinable
    public func child(of position: Tree.Position, slot: ChildSlot) -> Tree.Position? {
        guard let handle = try? _handle(position) else { return nil }
        guard let child = _storage.withColumn({ $0[handle].childHandles[slot.index] }) else { return nil }
        return _position(of: child)
    }

    /// Returns the position of the parent of the node at the given position.
    ///
    /// - Parameter position: The position of the child node.
    /// - Returns: The position of the parent, or `nil` if the node is the root.
    /// - Note: Returns `nil` if the position is invalid (stale or out of bounds).
    @inlinable
    public func parent(of position: Tree.Position) -> Tree.Position? {
        guard let handle = try? _handle(position) else { return nil }
        guard let parentHandle = _storage.withColumn({ $0[handle].parentHandle }) else {
            return nil
        }
        return _position(of: parentHandle)
    }

    /// Returns whether the node at the given position is a leaf (has no children).
    ///
    /// - Parameter position: The position to check.
    /// - Returns: `true` if the node has no children, `false` otherwise.
    /// - Note: Returns `false` if the position is invalid (stale or out of bounds).
    @inlinable
    public func isLeaf(_ position: Tree.Position) -> Bool {
        guard let handle = try? _handle(position) else { return false }
        return _storage.withColumn { $0[handle].childCount == .zero }
    }

    /// Returns the number of children of the node at the given position.
    ///
    /// - Parameter position: The position to check.
    /// - Returns: The number of occupied child slots, or `nil` if position is invalid.
    @inlinable
    public func childCount(of position: Tree.Position) -> Count? {
        guard let handle = try? _handle(position) else { return nil }
        return _storage.withColumn { $0[handle].childCount }
    }

    /// Returns the position of the leftmost (first non-empty) child.
    ///
    /// - Parameter position: The position of the parent node.
    /// - Returns: The position of the leftmost child, or `nil` if no children exist.
    @inlinable
    public func leftmostChild(of position: Tree.Position) -> Tree.Position? {
        guard let handle = try? _handle(position) else { return nil }
        let childHandles = _storage.withColumn { $0[handle].childHandles }
        for slot in 0..<n {
            if let child = childHandles[slot] {
                return _position(of: child)
            }
        }
        return nil
    }

    /// Returns the position of the rightmost (last non-empty) child.
    ///
    /// - Parameter position: The position of the parent node.
    /// - Returns: The position of the rightmost child, or `nil` if no children exist.
    @inlinable
    public func rightmostChild(of position: Tree.Position) -> Tree.Position? {
        guard let handle = try? _handle(position) else { return nil }
        let childHandles = _storage.withColumn { $0[handle].childHandles }
        for slot in stride(from: n - 1, through: 0, by: -1) {
            if let child = childHandles[slot] {
                return _position(of: child)
            }
        }
        return nil
    }
}

// MARK: - Binary Tree Navigation Convenience (n == 2)

extension Tree.N where Element: ~Copyable, n == 2 {

    /// Returns the position of the left child of the node at the given position.
    ///
    /// - Parameter position: The position of the parent node.
    /// - Returns: The position of the left child, or `nil` if there is no left child.
    /// - Note: Returns `nil` if the position is invalid (stale or out of bounds).
    @inlinable
    public func left(of position: Tree.Position) -> Tree.Position? {
        child(of: position, slot: .left)
    }

    /// Returns the position of the right child of the node at the given position.
    ///
    /// - Parameter position: The position of the parent node.
    /// - Returns: The position of the right child, or `nil` if there is no right child.
    /// - Note: Returns `nil` if the position is invalid (stale or out of bounds).
    @inlinable
    public func right(of position: Tree.Position) -> Tree.Position? {
        child(of: position, slot: .right)
    }
}

// MARK: - Insert Operations (~Copyable)

extension Tree.N where Element: ~Copyable {

    /// Inserts an element at the specified position.
    ///
    /// - Parameters:
    ///   - element: The element to insert.
    ///   - position: Where to insert the element.
    /// - Returns: The position of the newly inserted node (with token for validation).
    /// - Throws: ``Error/slotOccupied`` if the child slot is already occupied,
    ///           ``Error/invalidPosition`` if the parent position is invalid or stale.
    @inlinable
    @discardableResult
    public mutating func insert(
        _ element: consuming Element,
        at position: InsertPosition
    ) throws(__TreeNError) -> Tree.Position {
        switch position {
        case .root:
            guard _rootHandle == nil else {
                throw .slotOccupied
            }
            let handle = _insert(node: Node(element: element))
            _rootHandle = handle
            return _position(of: handle)

        case .child(of: let parent, let slot):
            // Validate parent position (token check)
            let parentHandle = try _handle(parent)
            // Check child slot is empty (slot valid before insert)
            guard _storage.withColumn({ $0[parentHandle].childHandles[slot.index] == nil }) else {
                throw .slotOccupied
            }
            // Insert (may grow — the parent handle stays valid across growth by
            // the grow(to:) door's incarnation-history contract)
            let handle = _insert(node: Node(element: element, parentHandle: parentHandle))
            _storage.withUnique { column in
                column[parentHandle].childHandles[slot.index] = handle
                column[parentHandle].childCount += .one
            }
            return _position(of: handle)
        }
    }

    /// Removes the leaf node at the specified position.
    ///
    /// - Parameter position: The position of the node to remove. Must be a leaf.
    /// - Returns: The element that was stored at the position.
    /// - Throws: ``Error/invalidPosition`` if the position is invalid or stale,
    ///           ``Error/cannotRemoveNonLeaf`` if the node has children.
    @inlinable
    @discardableResult
    public mutating func remove(at position: Tree.Position) throws(__TreeNError) -> Element {
        // Validate position (token check)
        let handle = try _handle(position)

        guard _storage.withColumn({ $0[handle].childCount == .zero }) else {
            throw .cannotRemoveNonLeaf
        }

        // Update parent's child slot (or clear root)
        _unlink(handle)

        // Move element out and release slot
        let node = _remove(handle)
        return node.element
    }

    /// Removes the subtree rooted at the specified position.
    ///
    /// All nodes in the subtree are removed and their elements are deinitialized
    /// in post-order (children before parents).
    ///
    /// - Parameter position: The position of the root of the subtree to remove.
    /// - Throws: ``Error/invalidPosition`` if the position is invalid or stale.
    @inlinable
    public mutating func removeSubtree(at position: Tree.Position) throws(__TreeNError) {
        // Validate position (token check)
        let handle = try _handle(position)

        // Update parent's child slot (or clear root)
        _unlink(handle)

        // Iterative post-order removal using explicit stack
        var pending = Stack<Store.Generational.Handle>()
        var lastVisited: Store.Generational.Handle? = nil

        pending.push(handle)

        while !pending.isEmpty {
            let current = pending.peek { $0 }!
            let childHandles = _storage.withColumn { $0[current].childHandles }

            // Find rightmost existing child
            var rightmostChild: Store.Generational.Handle? = nil
            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    rightmostChild = child
                    break
                }
            }

            // Find leftmost existing child
            var leftmostChild: Store.Generational.Handle? = nil
            for slot in 0..<n {
                if let child = childHandles[slot] {
                    leftmostChild = child
                    break
                }
            }

            // Process current if:
            // 1. It's a leaf (no children), OR
            // 2. We came from the rightmost child, OR
            // 3. We came from leftmost child AND no other children exist
            let isLeaf = rightmostChild == nil
            let cameFromRightmost = rightmostChild != nil && rightmostChild == lastVisited
            let cameFromLeftmostNoOther = leftmostChild != nil && leftmostChild == lastVisited && leftmostChild == rightmostChild

            if isLeaf || cameFromRightmost || cameFromLeftmostNoOther {
                _ = pending.pop()
                _ = _remove(current)
                lastVisited = current
            } else {
                // Push children in reverse order (rightmost first so leftmost is processed first)
                for slot in stride(from: n - 1, through: 0, by: -1) {
                    if let child = childHandles[slot] {
                        pending.push(child)
                    }
                }
            }
        }
    }

    /// Accesses the element at the specified position via a borrowing closure.
    ///
    /// - Parameters:
    ///   - position: The position of the node.
    ///   - body: A closure that receives a borrowing reference to the element.
    /// - Returns: The value returned by `body`, or `nil` if the position is invalid or stale.
    @inlinable
    public func peek<R>(at position: Tree.Position, _ body: (borrowing Element) -> R) -> R? {
        guard let handle = try? _handle(position) else { return nil }
        return _storage.withColumn { body($0[handle].element) }
    }

    /// Clears all nodes from the tree.
    @inlinable
    public mutating func clear() {
        _storage.withUnique { $0.removeAll() }
        for index in _handles.indices {
            _handles[index] = nil
        }
        _rootHandle = nil
    }

    /// Computes the height of the tree.
    ///
    /// The height is the length of the longest path from the root to a leaf.
    /// An empty tree returns `nil`, a single-node tree has height `.zero`.
    ///
    /// Uses iterative traversal to avoid stack overflow on deep trees.
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

extension Tree.N where Element: ~Copyable {

    /// Iterates over all elements in pre-order using a borrowing closure.
    ///
    /// Uses iterative traversal to avoid stack overflow on deep trees.
    /// - Parameter body: A closure called with each element in pre-order.
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

            // Push children in reverse order so first child is processed first
            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    pending.push(child)
                }
            }
        }
    }

    /// Iterates over all elements in post-order using a borrowing closure.
    ///
    /// Uses iterative traversal to avoid stack overflow on deep trees.
    /// - Parameter body: A closure called with each element in post-order.
    @inlinable
    public func forEachPostOrder(_ body: (borrowing Element) -> Void) {
        guard let rootHandle = _rootHandle else { return }
        var pending = Stack<Store.Generational.Handle>()
        var lastVisited: Store.Generational.Handle? = nil
        pending.push(rootHandle)

        while !pending.isEmpty {
            let current = pending.peek { $0 }!
            let childHandles = _storage.withColumn { $0[current].childHandles }

            // Find rightmost existing child
            var rightmostChild: Store.Generational.Handle? = nil
            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    rightmostChild = child
                    break
                }
            }

            // Find leftmost existing child
            var leftmostChild: Store.Generational.Handle? = nil
            for slot in 0..<n {
                if let child = childHandles[slot] {
                    leftmostChild = child
                    break
                }
            }

            // Process current if:
            // 1. It's a leaf (no children), OR
            // 2. We came from the rightmost child, OR
            // 3. We came from leftmost child AND no other children exist
            let isLeaf = rightmostChild == nil
            let cameFromRightmost = rightmostChild != nil && rightmostChild == lastVisited
            let cameFromLeftmostNoOther = leftmostChild != nil && leftmostChild == lastVisited && leftmostChild == rightmostChild

            if isLeaf || cameFromRightmost || cameFromLeftmostNoOther {
                _ = pending.pop()
                _storage.withColumn { body($0[current].element) }
                lastVisited = current
            } else {
                // Push children in reverse order (rightmost first so leftmost is processed first)
                for slot in stride(from: n - 1, through: 0, by: -1) {
                    if let child = childHandles[slot] {
                        pending.push(child)
                    }
                }
            }
        }
    }

    /// Iterates over all elements in level-order (breadth-first) using a borrowing closure.
    ///
    /// - Parameter body: A closure called with each element in level-order.
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

extension Tree.N where Element: ~Copyable, n == 2 {

    /// Iterates over all elements in in-order using a borrowing closure.
    ///
    /// In-order traversal visits left subtree, then root, then right subtree.
    /// Only available for binary trees (n == 2).
    ///
    /// Uses iterative traversal to avoid stack overflow on deep trees.
    /// - Parameter body: A closure called with each element in in-order.
    @inlinable
    public func forEachInOrder(_ body: (borrowing Element) -> Void) {
        guard let rootHandle = _rootHandle else { return }
        var pending = Stack<Store.Generational.Handle>()
        var current: Store.Generational.Handle? = rootHandle

        while current != nil || !pending.isEmpty {
            // Go to leftmost node
            while let c = current {
                pending.push(c)
                current = _storage.withColumn { $0[c].childHandles[0] }
            }

            // Process node
            let c = pending.pop()!
            current = _storage.withColumn { (column) -> Store.Generational.Handle? in
                body(column[c].element)
                return column[c].childHandles[1]
            }
        }
    }
}

// MARK: - Copyable Element Extensions

extension Tree.N where Element: Copyable {

    /// Inserts an element at the specified position (CoW-aware).
    ///
    /// Uniqueness is restored by the `withUnique` gate inside each storage
    /// mutation, so a tree sharing its column with a copy detaches before writing.
    @inlinable
    @discardableResult
    public mutating func insert(
        _ element: Element,
        at position: InsertPosition
    ) throws(__TreeNError) -> Tree.Position {
        switch position {
        case .root:
            guard _rootHandle == nil else {
                throw .slotOccupied
            }
            let handle = _insert(node: Node(element: element))
            _rootHandle = handle
            return _position(of: handle)

        case .child(of: let parent, let slot):
            // Validate parent position (token check)
            let parentHandle = try _handle(parent)
            // Check child slot is empty (slot valid before insert)
            guard _storage.withColumn({ $0[parentHandle].childHandles[slot.index] == nil }) else {
                throw .slotOccupied
            }
            // Insert (may grow — see the ~Copyable twin)
            let handle = _insert(node: Node(element: element, parentHandle: parentHandle))
            _storage.withUnique { column in
                column[parentHandle].childHandles[slot.index] = handle
                column[parentHandle].childCount += .one
            }
            return _position(of: handle)
        }
    }

    /// Returns the element at the specified position.
    ///
    /// - Parameter position: The position of the node.
    /// - Returns: The element at the position, or `nil` if invalid or stale.
    @inlinable
    public func peek(at position: Tree.Position) -> Element? {
        guard let handle = try? _handle(position) else { return nil }
        return _storage.withColumn { $0[handle].element }
    }
}

// MARK: - Conditional Copyable

extension Tree.N.Node: Copyable where Element: Copyable {}
extension Tree.N: Copyable where Element: Copyable {}

// MARK: - Sendable

extension Tree.N: @unsafe @unchecked Sendable where Element: Sendable {}
