internal import Iterator_Primitive
internal import Iterator_Protocol
public import Stack_Primitive
internal import Stack_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension __TreeNOrder.Pre {

    public struct Iterator<S: __TreeNStorage>: ~Copyable, Iterator_Primitive.Iterator.`Protocol`
    where S.Element: Copyable {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        var pending: Stack<Store.Generational.Handle>

        @usableFromInline
        init(tree: __Tree<S>) {
            self.tree = tree
            self.pending = Stack<Store.Generational.Handle>()
            if let rootHandle = tree._rootHandle {
                self.pending.push(rootHandle)
            }
        }

        @inlinable
        public mutating func next() -> S.Element? {
            guard let handle = pending.pop() else { return nil }

            let value = tree._value(of: handle)

            let children = tree._childHandles(of: handle)
            for i in (0..<children.count).reversed() {
                pending.push(children[i])
            }

            return value
        }
    }
}
