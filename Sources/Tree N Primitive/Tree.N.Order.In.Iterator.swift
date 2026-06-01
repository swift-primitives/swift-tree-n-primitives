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

// MARK: - In-Order Iterator

extension Tree.N.Order.In {

    /// An iterator for in-order traversal.
    ///
    /// Only available for binary trees (n == 2).
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>

        @usableFromInline
        var pending: Stack<Index<Tree.N<n>.Node>>

        @usableFromInline
        var current: Index<Tree.N<n>.Node>?

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Stack<Index<Tree.N<n>.Node>>()
            self.current = tree._rootIndex
        }

        @inlinable
        public mutating func next() -> Element? {
            while current != nil || !pending.isEmpty {
                // Go to leftmost node
                while let c = current {
                    pending.push(c)
                    current = unsafe tree._arena.pointer(at: c).pointee.childIndices[0]
                }

                // Process node
                let c = pending.pop()!
                let nodePtr = unsafe tree._arena.pointer(at: c)
                let element = unsafe nodePtr.pointee.element

                // Move to right subtree
                current = unsafe nodePtr.pointee.childIndices[1]

                return element
            }

            return nil
        }
    }
}
