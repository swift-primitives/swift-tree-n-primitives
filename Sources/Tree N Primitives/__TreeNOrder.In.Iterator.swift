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

internal import Iterator_Primitive
internal import Iterator_Protocol
public import Stack_Primitive
internal import Stack_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension __TreeNOrder.In {

    /// An iterator for in-order traversal (left subtree, root, right subtree).
    ///
    /// Only available for binary trees (`S.Address == __TreeNChildSlot<2>`).
    ///
    /// Move-only (`~Copyable`): the traversal scratch is the canonical direct
    /// `Stack<Handle>`, which is move-only regardless of element (the W2 stack reshape);
    /// the whole `Iterator.Protocol` / `Iterable` / `Materializing` machinery suppresses
    /// `~Copyable`, so the iterator rides it without a CoW column (seat D3 ruling (a)).
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

        /// Advances to the next node in in-order (left subtree, then root, then
        /// right subtree), or returns `nil` when traversal is exhausted.
        @inlinable
        public mutating func next() -> S.Element? {
            while current != nil || !pending.isEmpty {
                // Go to leftmost node
                while let c = current {
                    pending.push(c)
                    current = tree._childHandle(of: c, at: .left)
                }

                // Process node
                guard let c = pending.pop() else { return nil }
                let value = tree._value(of: c)

                // Move to right subtree
                current = tree._childHandle(of: c, at: .right)

                return value
            }

            return nil
        }
    }
}
