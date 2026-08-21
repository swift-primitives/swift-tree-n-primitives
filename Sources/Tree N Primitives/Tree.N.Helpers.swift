public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension __Tree where S: __TreeNStorage & ~Copyable {

    public typealias ChildSlot = S.Address

    public typealias Order = __TreeNOrder

    @inlinable
    public static var arity: Int { S._arity }

    @usableFromInline
    var _rootHandle: Store.Generational.Handle? {
        @inlinable get { _storage._rootHandle }
        @inlinable set { _storage._rootHandle = newValue }
    }

    @inlinable
    package func _parentHandle(of handle: Store.Generational.Handle) -> Store.Generational.Handle? {
        _storage._parentHandle(of: handle)
    }

    @inlinable
    package func _childHandles(of handle: Store.Generational.Handle) -> [Store.Generational.Handle]
    {
        var children: [Store.Generational.Handle] = []
        _storage._forEachChild(at: handle) { children.append($0) }
        return children
    }

    @inlinable
    package func _childHandle(
        of handle: Store.Generational.Handle,
        at address: S.Address
    ) -> Store.Generational.Handle? {
        _storage._childHandle(at: handle, address: address)
    }
}

extension __Tree where S: __TreeNStorage, S.Element: Copyable {

    @inlinable
    package func _value(of handle: Store.Generational.Handle) -> S.Element {
        _storage._withElement(at: handle) { $0 }
    }
}
