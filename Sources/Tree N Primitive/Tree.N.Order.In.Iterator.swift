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

// MARK: - In-Order Iterator

extension Tree.N.Order.In {

    /// An iterator for in-order traversal.
    ///
    /// Only available for binary trees (n == 2).
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>

        @usableFromInline
        var pending: Stack<Store.Generational.Handle>

        @usableFromInline
        var current: Store.Generational.Handle?

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Stack<Store.Generational.Handle>()
            self.current = tree._rootHandle
        }

        @inlinable
        public mutating func next() -> Element? {
            while current != nil || !pending.isEmpty {
                // Go to leftmost node
                while let c = current {
                    pending.push(c)
                    current = tree._storage.withLinks(at: c) { $0[0] }
                }

                // Process node
                let c = pending.pop()!
                let element = tree._storage.withElement(at: c) { $0 }
                let right = tree._storage.withLinks(at: c) { $0[1] }

                // Move to right subtree
                current = right

                return element
            }

            return nil
        }
    }
}
