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
            let element = tree._storage.withElement(at: handle) { $0 }
            let childHandles = tree._storage.withLinks(at: handle) { $0 }

            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childHandles[slot] {
                    pending.push(child)
                }
            }

            return element
        }
    }
}
