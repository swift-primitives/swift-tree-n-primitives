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

extension __TreeNOrder.Level {

    /// A sequence that yields elements in level-order (breadth-first) traversal.
    @frozen
    public struct Sequence<S: __TreeNStorage> {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        init(tree: __Tree<S>) { self.tree = tree }
    }
}

// MARK: - Iterable (multipass, borrowing)

extension __TreeNOrder.Level.Sequence: Iterable where S.Element: Copyable {
    /// The multipass borrowing iterator for level-order traversal.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<__TreeNOrder.Level.Iterator<S>>

    /// Returns a borrowing iterator over the tree in level-order.
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<__TreeNOrder.Level.Iterator<S>>
    {
        Iterator_Primitive.Iterator.Materializing(__TreeNOrder.Level.Iterator<S>(tree: tree))
    }
}

// MARK: - Sequenceable (single-pass, consuming)

extension __TreeNOrder.Level.Sequence: Sequenceable where S.Element: Copyable {
    /// The consuming iterator for level-order traversal.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = __TreeNOrder.Level.Iterator<S>

    /// Consumes this sequence, yielding an iterator over the tree in level-order.
    public consuming func makeIterator() -> __TreeNOrder.Level.Iterator<S> {
        __TreeNOrder.Level.Iterator<S>(tree: tree)
    }
}
