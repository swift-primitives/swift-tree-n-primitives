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

// MARK: - Post-Order Iterator

extension Tree.N.Order.Post {

    /// An iterator for post-order traversal.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>

        @usableFromInline
        var pending: Stack<Index<Tree.N<n>.Node>>

        @usableFromInline
        var lastVisited: Index<Tree.N<n>.Node>?

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Stack<Index<Tree.N<n>.Node>>()
            self.lastVisited = nil

            // Push root if exists
            if let rootIndex = tree._rootIndex {
                pending.push(rootIndex)
            }
        }

        @inlinable
        public mutating func next() -> Element? {
            while !pending.isEmpty {
                let current = pending.peek()!
                let nodePtr = unsafe tree._arena.pointer(at: current)
                let childIndices = unsafe nodePtr.pointee.childIndices

                var rightmostChild: Index<Tree.N<n>.Node>? = nil
                for slot in stride(from: n - 1, through: 0, by: -1) {
                    if let child = childIndices[slot] {
                        rightmostChild = child
                        break
                    }
                }

                var leftmostChild: Index<Tree.N<n>.Node>? = nil
                for slot in 0..<n {
                    if let child = childIndices[slot] {
                        leftmostChild = child
                        break
                    }
                }

                let isLeaf = rightmostChild == nil
                let cameFromRightmost = rightmostChild != nil && rightmostChild == lastVisited
                let cameFromLeftmostNoOther = leftmostChild != nil && leftmostChild == lastVisited && leftmostChild == rightmostChild

                if isLeaf || cameFromRightmost || cameFromLeftmostNoOther {
                    _ = pending.pop()
                    lastVisited = current
                    return unsafe nodePtr.pointee.element
                } else {
                    for slot in stride(from: n - 1, through: 0, by: -1) {
                        if let child = childIndices[slot] {
                            pending.push(child)
                        }
                    }
                }
            }

            return nil
        }
    }
}
