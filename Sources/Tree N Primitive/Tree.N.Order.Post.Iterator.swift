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
public import Tree_Primitives_Core

// MARK: - Post-Order Iterator

extension Tree.N.Order.Post {

    /// An iterator for post-order traversal.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>

        @usableFromInline
        var pending: Stack<Store.Generational.Handle>

        @usableFromInline
        var lastVisited: Store.Generational.Handle?

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Stack<Store.Generational.Handle>()
            self.lastVisited = nil

            // Push root if exists
            if let rootHandle = tree._rootHandle {
                pending.push(rootHandle)
            }
        }

        @inlinable
        public mutating func next() -> Element? {
            while !pending.isEmpty {
                let current = pending.peek { $0 }!
                let childHandles = tree._storage.withLinks(at: current) { $0 }

                var rightmostChild: Store.Generational.Handle? = nil
                for slot in stride(from: n - 1, through: 0, by: -1) {
                    if let child = childHandles[slot] {
                        rightmostChild = child
                        break
                    }
                }

                var leftmostChild: Store.Generational.Handle? = nil
                for slot in 0..<n {
                    if let child = childHandles[slot] {
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
                    return tree._storage.withElement(at: current) { $0 }
                } else {
                    for slot in stride(from: n - 1, through: 0, by: -1) {
                        if let child = childHandles[slot] {
                            pending.push(child)
                        }
                    }
                }
            }

            return nil
        }
    }
}
