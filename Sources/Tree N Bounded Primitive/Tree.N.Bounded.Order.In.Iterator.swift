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

internal import Buffer_Arena_Primitives
public import Queue_Primitives
internal import Stack_Primitives
internal import Iterator_Primitive
internal import Iterator_Protocol

// MARK: - In-Order Iterator

extension Tree.N.Bounded.Order.In {

    /// An iterator for in-order traversal.
    ///
    /// Only available for binary trees (n == 2).
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>.Bounded

        @usableFromInline
        var pending: Stack<Index<Tree.N<n>.Node>>

        @usableFromInline
        var current: Index<Tree.N<n>.Node>?

        package init(tree: Tree.N<n>.Bounded) {
            self.tree = tree
            self.pending = Stack<Index<Tree.N<n>.Node>>()
            self.current = tree._rootIndex
        }

        @inlinable
        public mutating func next() -> Element? {
            while current != nil || !pending.isEmpty {
                while let c = current {
                    pending.push(c)
                    current = tree._arena[c].childIndices[0]
                }

                let c = pending.pop()!
                let element = tree._arena[c].element
                current = tree._arena[c].childIndices[1]

                return element
            }
            return nil
        }
    }
}
