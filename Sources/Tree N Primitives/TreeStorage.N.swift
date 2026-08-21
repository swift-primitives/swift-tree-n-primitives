public import Index_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension TreeStorage {

    public struct N<Element: ~Copyable, let n: Int>: ~Copyable {

        public typealias Address = __TreeNChildSlot<n>

        @usableFromInline
        var _arena: __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>

        @inlinable
        public init() {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>()
        }

        @inlinable
        public init(minimumCapacity: Index<Element>.Count) {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>(
                minimumCapacity: minimumCapacity
            )
        }

        @inlinable
        public init() where Element: Copyable {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>()
        }

        @inlinable
        public init(minimumCapacity: Index<Element>.Count) where Element: Copyable {
            _arena = __TreeArena<Element, InlineArray<n, Store.Generational.Handle?>>(
                minimumCapacity: minimumCapacity
            )
        }
    }
}

extension TreeStorage.N: __TreeStorage where Element: ~Copyable {

    @inlinable
    public var _count: Index<Element>.Count { _arena.count }

    @inlinable
    public var _rootHandle: Store.Generational.Handle? {
        get { _arena.rootHandle }
        set { _arena.rootHandle = newValue }
    }

    @inlinable
    public func _liveHandle(_ position: __TreePosition) -> Store.Generational.Handle? {
        _arena.liveHandle(position)
    }

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

    @inlinable
    public mutating func _removeNode(_ handle: Store.Generational.Handle) -> Element {
        _arena.removeNode(handle)
    }

    @inlinable
    public mutating func _removeAll() { _arena.removeAll() }

    @inlinable
    public func _parentHandle(of handle: Store.Generational.Handle) -> Store.Generational.Handle? {
        _arena.parentHandle(of: handle)
    }

    @inlinable
    public func _withElement<R: ~Copyable>(
        at handle: Store.Generational.Handle,
        _ body: (borrowing Element) -> R
    ) -> R {
        _arena.withElement(at: handle, body)
    }

    @inlinable
    public mutating func _withElementMut<R: ~Copyable>(
        at handle: Store.Generational.Handle,
        _ body: (inout Element) -> R
    ) -> R {
        _arena.withElementMut(at: handle, body)
    }

    @inlinable
    public func _childHandle(
        at handle: Store.Generational.Handle,
        address: __TreeNChildSlot<n>
    ) -> Store.Generational.Handle? {
        _arena.withLinks(at: handle) { $0[address.index] }
    }

    @inlinable
    public func _validateLink(
        to parent: Store.Generational.Handle,
        at address: __TreeNChildSlot<n>
    ) throws(__TreeError) {
        let occupied = _arena.withLinks(at: parent) { $0[address.index] != nil }
        if occupied { throw .slotOccupied }
    }

    @inlinable
    public mutating func _linkChild(
        _ child: Store.Generational.Handle,
        to parent: Store.Generational.Handle,
        at address: __TreeNChildSlot<n>
    ) {
        _arena.withLinksMut(at: parent) { $0[address.index] = child }
    }

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

extension TreeStorage.N: __TreeNStorage where Element: ~Copyable {

    @inlinable
    public static var _arity: Int { n }
}

extension TreeStorage.N: Copyable where Element: Copyable {}

extension TreeStorage.N: Sendable where Element: Sendable {}
