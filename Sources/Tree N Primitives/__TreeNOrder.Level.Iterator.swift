public import Buffer_Ring_Primitive
public import Column_Primitives
internal import Iterator_Primitive
internal import Iterator_Protocol
public import Ownership_Shared_Primitive
public import Queue_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension __TreeNOrder.Level {

    public struct Iterator<S: __TreeNStorage>: Iterator_Primitive.Iterator.`Protocol`
    where S.Element: Copyable {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        var pending:
            __Queue<
                Ownership.Shared<Store.Generational.Handle, Column.Ring<Store.Generational.Handle>>
            >

        @usableFromInline
        init(tree: __Tree<S>) {
            self.tree = tree
            self.pending = __Queue<
                Ownership.Shared<Store.Generational.Handle, Column.Ring<Store.Generational.Handle>>
            >()

            if let rootHandle = tree._rootHandle {
                pending.enqueue(rootHandle)
            }
        }

        @inlinable
        public mutating func next() -> S.Element? {
            guard let handle = pending.dequeue() else { return nil }

            let value = tree._value(of: handle)

            for child in tree._childHandles(of: handle) {
                pending.enqueue(child)
            }

            return value
        }
    }
}
