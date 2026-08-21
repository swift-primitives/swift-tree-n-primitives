public import Property_Primitives
public import Stack_Primitives
public import Tree_Primitives

extension Property_Primitives.Property.Borrow
where Base: __TreeProtocol & ~Copyable, Tag == __TreeForEach, Base.Address == __TreeNChildSlot<2> {

    @inlinable
    public func inOrder(_ body: (borrowing Base.Element) -> Void) {
        guard let root = base.value.root else { return }
        var pending = Stack<__TreePosition>()
        var current: __TreePosition? = root

        while current != nil || !pending.isEmpty {

            while let c = current {
                pending.push(c)
                current = base.value._child(of: c, at: .left)
            }

            guard let c = pending.pop() else { break }
            if let handle = base.value._liveHandle(c) {
                base.value._withElement(at: handle) { body($0) }
            }
            current = base.value._child(of: c, at: .right)
        }
    }
}
