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

// MARK: - Pre-Order Iterator

extension Tree.N.Order.Pre {

    /// An iterator for pre-order traversal.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>

        @usableFromInline
        var pending: Stack<Store.Generational.Handle>

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Stack<Store.Generational.Handle>()
            if let rootHandle = tree._rootHandle {
                self.pending.push(rootHandle)
            }
        }

        @inlinable
        public mutating func next() -> Element? {
            guard !pending.isEmpty else { return nil }

            let handle = pending.pop()!
            let (element, childHandles) = tree._storage.withColumn {
                (column) -> (Element, InlineArray<n, Store.Generational.Handle?>) in
                (column[handle].element, column[handle].childHandles)
            }

            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    pending.push(child)
                }
            }

            return element
        }
    }
}
