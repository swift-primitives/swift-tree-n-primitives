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

public import Tree_N_Bounded_Primitive
public import Iterable
public import Iterator_Primitive
public import Iterator_Chunk_Primitives
public import Sequence_Protocol_Primitives

// MARK: - Iterable + Sequenceable Conformances (isolated per [MOD-004] / [MOD-036])
//
// The `Tree.N.Bounded.Order.*.Sequence` structs + the storage-touching `@inlinable`
// iterators are co-located with the Bounded arena storage in the
// `Tree N Bounded Primitive` type module. Only the Copyable-imposing iteration
// conformances are isolated here.
//
// Both `Iterable` and `Sequenceable` declare `associatedtype Iterator`, which Swift
// unifies; the dual conformer splits the bindings with `@_implements`. The scalar
// iterator is the sibling `Tree.N.Bounded.Order.*.Iterator` — referenced fully-qualified
// (`Tree<Element>.N<n>.Bounded.Order.*.Iterator`) so the bare name `Iterator` does not
// resolve to `Self.Iterator` (the associated type being defined).

// MARK: Pre

extension Tree.N.Bounded.Order.Pre.Sequence: Iterable where Element: Copyable {
    @_implements(Iterable, Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.Pre.Iterator>

    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.Pre.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Bounded.Order.Pre.Iterator(tree: tree))
    }
}

extension Tree.N.Bounded.Order.Pre.Sequence: Sequenceable where Element: Copyable {
    @_implements(Sequenceable, Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Bounded.Order.Pre.Iterator

    public consuming func makeIterator() -> Tree<Element>.N<n>.Bounded.Order.Pre.Iterator {
        Tree<Element>.N<n>.Bounded.Order.Pre.Iterator(tree: tree)
    }
}

// MARK: Post

extension Tree.N.Bounded.Order.Post.Sequence: Iterable where Element: Copyable {
    @_implements(Iterable, Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.Post.Iterator>

    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.Post.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Bounded.Order.Post.Iterator(tree: tree))
    }
}

extension Tree.N.Bounded.Order.Post.Sequence: Sequenceable where Element: Copyable {
    @_implements(Sequenceable, Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Bounded.Order.Post.Iterator

    public consuming func makeIterator() -> Tree<Element>.N<n>.Bounded.Order.Post.Iterator {
        Tree<Element>.N<n>.Bounded.Order.Post.Iterator(tree: tree)
    }
}

// MARK: Level

extension Tree.N.Bounded.Order.Level.Sequence: Iterable where Element: Copyable {
    @_implements(Iterable, Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.Level.Iterator>

    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.Level.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Bounded.Order.Level.Iterator(tree: tree))
    }
}

extension Tree.N.Bounded.Order.Level.Sequence: Sequenceable where Element: Copyable {
    @_implements(Sequenceable, Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Bounded.Order.Level.Iterator

    public consuming func makeIterator() -> Tree<Element>.N<n>.Bounded.Order.Level.Iterator {
        Tree<Element>.N<n>.Bounded.Order.Level.Iterator(tree: tree)
    }
}

// MARK: In

extension Tree.N.Bounded.Order.In.Sequence: Iterable where Element: Copyable {
    @_implements(Iterable, Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.In.Iterator>

    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Tree<Element>.N<n>.Bounded.Order.In.Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Tree<Element>.N<n>.Bounded.Order.In.Iterator(tree: tree))
    }
}

extension Tree.N.Bounded.Order.In.Sequence: Sequenceable where Element: Copyable {
    @_implements(Sequenceable, Iterator)
    public typealias SequenceableIterator = Tree<Element>.N<n>.Bounded.Order.In.Iterator

    public consuming func makeIterator() -> Tree<Element>.N<n>.Bounded.Order.In.Iterator {
        Tree<Element>.N<n>.Bounded.Order.In.Iterator(tree: tree)
    }
}
