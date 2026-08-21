public import Iterable
public import Iterator_Chunk_Primitives
public import Iterator_Primitive
public import Sequence_Primitives
public import Tree_Primitives

extension __TreeNOrder.In {

    @frozen
    public struct Sequence<S: __TreeNStorage> where S.Address == __TreeNChildSlot<2> {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        init(tree: __Tree<S>) { self.tree = tree }
    }
}

extension __TreeNOrder.In.Sequence: Iterable where S.Element: Copyable {

    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<__TreeNOrder.In.Iterator<S>>

    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<__TreeNOrder.In.Iterator<S>>
    {
        Iterator_Primitive.Iterator.Materializing(__TreeNOrder.In.Iterator<S>(tree: tree))
    }
}

extension __TreeNOrder.In.Sequence: Sequenceable where S.Element: Copyable {

    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = __TreeNOrder.In.Iterator<S>

    public consuming func makeIterator() -> __TreeNOrder.In.Iterator<S> {
        __TreeNOrder.In.Iterator<S>(tree: tree)
    }
}
