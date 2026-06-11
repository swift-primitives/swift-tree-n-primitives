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

public import Store_Primitive
public import Storage_Generational_Primitives
public import Shared_Primitive
public import Stack_Primitive
internal import Stack_Primitives
internal import Iterator_Primitive
internal import Iterator_Protocol

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
                    current = tree._storage.withColumn { $0[c].childHandles[0] }
                }

                // Process node
                let c = pending.pop()!
                let (element, right) = tree._storage.withColumn {
                    (column) -> (Element, Store.Generational.Handle?) in
                    (column[c].element, column[c].childHandles[1])
                }

                // Move to right subtree
                current = right

                return element
            }

            return nil
        }
    }
}
