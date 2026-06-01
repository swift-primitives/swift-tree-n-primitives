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
internal import Iterator_Primitive
internal import Iterator_Protocol

// MARK: - Level-Order Iterator

extension Tree.N.Order.Level {

    /// An iterator for level-order traversal.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>

        @usableFromInline
        var pending: Queue<Index<Tree.N<n>.Node>>

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Queue<Index<Tree.N<n>.Node>>()

            if let rootIndex = tree._rootIndex {
                pending.enqueue(rootIndex)
            }
        }

        @inlinable
        public mutating func next() -> Element? {
            guard !pending.isEmpty else { return nil }

            let index = pending.dequeue()!
            let nodePtr = unsafe tree._arena.pointer(at: index)
            let element = unsafe nodePtr.pointee.element
            let childIndices = unsafe nodePtr.pointee.childIndices

            for slot in 0..<n {
                if let child = childIndices[slot] {
                    pending.enqueue(child)
                }
            }

            return element
        }
    }
}
