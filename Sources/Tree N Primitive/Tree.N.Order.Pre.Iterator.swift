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

public import Queue_Primitives
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
        var pending: Stack<Index<Tree.N<n>.Node>>

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Stack<Index<Tree.N<n>.Node>>()
            if let rootIndex = tree._rootIndex {
                self.pending.push(rootIndex)
            }
        }

        @inlinable
        public mutating func next() -> Element? {
            guard !pending.isEmpty else { return nil }

            let index = pending.pop()!
            let element = tree._arena[index].element
            let childIndices = tree._arena[index].childIndices

            for slot in stride(from: n - 1, through: 0, by: -1) {
                if let child = childIndices[slot] {
                    pending.push(child)
                }
            }

            return element
        }
    }
}
