public import Iterable
public import Iterator_Chunk_Primitives
public import Iterator_Primitive
public import Sequence_Primitives
public import Tree_Primitives

extension __TreeNOrder.Level {

    @frozen
    public struct Sequence<S: __TreeNStorage> {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        init(tree: __Tree<S>) { self.tree = tree }
    }
}

extension __TreeNOrder.Level.Sequence: Iterable where S.Element: Copyable {

    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<__TreeNOrder.Level.Iterator<S>>

    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<__TreeNOrder.Level.Iterator<S>>
    {
        Iterator_Primitive.Iterator.Materializing(__TreeNOrder.Level.Iterator<S>(tree: tree))
    }
}

extension __TreeNOrder.Level.Sequence: Sequenceable where S.Element: Copyable {

    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = __TreeNOrder.Level.Iterator<S>

    public consuming func makeIterator() -> __TreeNOrder.Level.Iterator<S> {
        __TreeNOrder.Level.Iterator<S>(tree: tree)
    }
}
