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

public import Iterable
public import Iterator_Chunk_Primitives
public import Iterator_Primitive
public import Sequence_Primitives
public import Tree_Primitives

extension __TreeNOrder.In {

    /// A sequence that yields elements in in-order traversal.
    ///
    /// In-order traversal visits left subtree, then root, then right subtree.
    /// Only available for binary trees (`S.Address == __TreeNChildSlot<2>`).
    @frozen
    public struct Sequence<S: __TreeNStorage> where S.Address == __TreeNChildSlot<2> {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        init(tree: __Tree<S>) { self.tree = tree }
    }
}

// MARK: - Iterable (multipass, borrowing)

extension __TreeNOrder.In.Sequence: Iterable where S.Element: Copyable {
    /// The multipass borrowing iterator for in-order traversal.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<__TreeNOrder.In.Iterator<S>>

    /// Returns a borrowing iterator over the tree in in-order.
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<__TreeNOrder.In.Iterator<S>>
    {
        Iterator_Primitive.Iterator.Materializing(__TreeNOrder.In.Iterator<S>(tree: tree))
    }
}

// MARK: - Sequenceable (single-pass, consuming)

extension __TreeNOrder.In.Sequence: Sequenceable where S.Element: Copyable {
    /// The consuming iterator for in-order traversal.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = __TreeNOrder.In.Iterator<S>

    /// Consumes this sequence, yielding an iterator over the tree in in-order.
    public consuming func makeIterator() -> __TreeNOrder.In.Iterator<S> {
        __TreeNOrder.In.Iterator<S>(tree: tree)
    }
}
