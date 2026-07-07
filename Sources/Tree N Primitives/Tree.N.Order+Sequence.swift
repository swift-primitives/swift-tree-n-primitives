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
public import Sequence_Protocol_Primitives
public import Tree_N_Primitive

// MARK: - Iterable + Sequenceable Conformances (isolated per [MOD-004] / [MOD-036])
//
// The `Tree.N.Order.*.Sequence` structs and the storage-touching `@inlinable`
// Order iterators are co-located with the arena storage in the `Tree N Primitive`
// type module (handoff MUST + [MOD-036]: internal `@usableFromInline` storage +
// cross-module `@inlinable` would fail). Only the Copyable-imposing iteration
// conformances are isolated here so the lean `~Copyable` type surface stays
// poison-free per [MOD-004].
//
// Both `Iterable` and `Sequenceable` declare `associatedtype Iterator`, which Swift
// unifies; the dual conformer splits the two bindings with `@_implements`. The scalar
// iterator is the sibling `Tree.N.Order.*.Iterator` — referenced fully-qualified
// (`Tree<Element>.N<n>.Order.*.Iterator`) so the bare name `Iterator` does not resolve
// to `Self.Iterator` (the associated type being defined).

// MARK: Pre

extension Tree.N.Order.Pre.Sequence: Iterable where Element: Copyable {
    /// The multipass borrowing iterator for pre-order traversal.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.Pre.Iterator>

    /// Returns a borrowing iterator over the tree in pre-order.
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.Pre.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Order.Pre.Iterator(tree: tree))
    }
}

extension Tree.N.Order.Pre.Sequence: Sequenceable where Element: Copyable {
    /// The consuming iterator for pre-order traversal.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Order.Pre.Iterator

    /// Consumes this sequence, yielding an iterator over the tree in pre-order.
    public consuming func makeIterator() -> Tree<Element>.N<n>.Order.Pre.Iterator {
        Tree<Element>.N<n>.Order.Pre.Iterator(tree: tree)
    }
}

// MARK: Post

extension Tree.N.Order.Post.Sequence: Iterable where Element: Copyable {
    /// The multipass borrowing iterator for post-order traversal.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.Post.Iterator>

    /// Returns a borrowing iterator over the tree in post-order.
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.Post.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Order.Post.Iterator(tree: tree))
    }
}

extension Tree.N.Order.Post.Sequence: Sequenceable where Element: Copyable {
    /// The consuming iterator for post-order traversal.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Order.Post.Iterator

    /// Consumes this sequence, yielding an iterator over the tree in post-order.
    public consuming func makeIterator() -> Tree<Element>.N<n>.Order.Post.Iterator {
        Tree<Element>.N<n>.Order.Post.Iterator(tree: tree)
    }
}

// MARK: Level

extension Tree.N.Order.Level.Sequence: Iterable where Element: Copyable {
    /// The multipass borrowing iterator for level-order traversal.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.Level.Iterator>

    /// Returns a borrowing iterator over the tree in level-order.
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.Level.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Order.Level.Iterator(tree: tree))
    }
}

extension Tree.N.Order.Level.Sequence: Sequenceable where Element: Copyable {
    /// The consuming iterator for level-order traversal.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Order.Level.Iterator

    /// Consumes this sequence, yielding an iterator over the tree in level-order.
    public consuming func makeIterator() -> Tree<Element>.N<n>.Order.Level.Iterator {
        Tree<Element>.N<n>.Order.Level.Iterator(tree: tree)
    }
}

// MARK: In

extension Tree.N.Order.In.Sequence: Iterable where Element: Copyable {
    /// The multipass borrowing iterator for in-order traversal.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.In.Iterator>

    /// Returns a borrowing iterator over the tree in in-order.
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Order.In.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Order.In.Iterator(tree: tree))
    }
}

extension Tree.N.Order.In.Sequence: Sequenceable where Element: Copyable {
    /// The consuming iterator for in-order traversal.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Order.In.Iterator

    /// Consumes this sequence, yielding an iterator over the tree in in-order.
    public consuming func makeIterator() -> Tree<Element>.N<n>.Order.In.Iterator {
        Tree<Element>.N<n>.Order.In.Iterator(tree: tree)
    }
}
