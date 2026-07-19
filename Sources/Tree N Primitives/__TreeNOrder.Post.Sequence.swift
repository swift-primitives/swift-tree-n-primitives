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

extension __TreeNOrder.Post {

    /// A sequence that yields elements in post-order traversal.
    ///
    /// Post-order traversal visits children in slot order, then the root.
    @frozen
    public struct Sequence<S: __TreeNStorage> {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        init(tree: __Tree<S>) { self.tree = tree }
    }
}

// MARK: - Iterable (multipass, borrowing)

extension __TreeNOrder.Post.Sequence: Iterable where S.Element: Copyable {
    /// The multipass borrowing iterator for post-order traversal.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<__TreeNOrder.Post.Iterator<S>>

    /// Returns a borrowing iterator over the tree in post-order.
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<__TreeNOrder.Post.Iterator<S>>
    {
        Iterator_Primitive.Iterator.Materializing(__TreeNOrder.Post.Iterator<S>(tree: tree))
    }
}

// MARK: - Sequenceable (single-pass, consuming)

extension __TreeNOrder.Post.Sequence: Sequenceable where S.Element: Copyable {
    /// The consuming iterator for post-order traversal.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = __TreeNOrder.Post.Iterator<S>

    /// Consumes this sequence, yielding an iterator over the tree in post-order.
    public consuming func makeIterator() -> __TreeNOrder.Post.Iterator<S> {
        __TreeNOrder.Post.Iterator<S>(tree: tree)
    }
}
