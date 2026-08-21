internal import Iterator_Primitive
internal import Iterator_Protocol
public import Stack_Primitive
internal import Stack_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension __TreeNOrder.In {

    public struct Iterator<S: __TreeNStorage>: ~Copyable, Iterator_Primitive.Iterator.`Protocol`
    where S.Element: Copyable, S.Address == __TreeNChildSlot<2> {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        var pending: Stack<Store.Generational.Handle>

        @usableFromInline
        var current: Store.Generational.Handle?

        @usableFromInline
        init(tree: __Tree<S>) {
            self.tree = tree
            self.pending = Stack<Store.Generational.Handle>()
            self.current = tree._rootHandle
        }

        @inlinable
        public mutating func next() -> S.Element? {
            while current != nil || !pending.isEmpty {

                while let c = current {
                    pending.push(c)
                    current = tree._childHandle(of: c, at: .left)
                }

                guard let c = pending.pop() else { return nil }
                let value = tree._value(of: c)

                current = tree._childHandle(of: c, at: .right)

                return value
            }

            return nil
        }
    }
}
