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

public import Buffer_Ring_Primitive
public import Column_Primitives
internal import Iterator_Primitive
internal import Iterator_Protocol
public import Queue_Primitives
public import Shared_Primitive
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives_Core

// MARK: - Level-Order Iterator

extension Tree.N.Order.Level {

    /// An iterator for level-order traversal.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        let tree: Tree.N<n>

        /// The pending-node FIFO on the `Shared` ring column — the CoW flavor is
        /// required here (not the move-only direct ring) so the iterator struct
        /// itself stays `Copyable`, preserving its pre-reshape shape.
        @usableFromInline
        var pending: Queue<Shared<Store.Generational.Handle, Column.Ring<Store.Generational.Handle>>>

        package init(tree: Tree.N<n>) {
            self.tree = tree
            self.pending = Queue<Shared<Store.Generational.Handle, Column.Ring<Store.Generational.Handle>>>()

            if let rootHandle = tree._rootHandle {
                pending.enqueue(rootHandle)
            }
        }

        @inlinable
        public mutating func next() -> Element? {
            guard !pending.isEmpty else { return nil }

            let handle = pending.dequeue()!
            let element = tree._storage.withElement(at: handle) { $0 }
            let childHandles = tree._storage.withLinks(at: handle) { $0 }

            for slot in 0..<n {
                if let child = childHandles[slot] {
                    pending.enqueue(child)
                }
            }

            return element
        }
    }
}
