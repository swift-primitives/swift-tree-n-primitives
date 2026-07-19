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

import Testing
import Tree_N_Primitives_Test_Support

@testable import Buffer_Primitives
@testable import Tree_N_Primitives

// MARK: - Performance Tests

@Suite(.serialized)
struct `Tree Binary Performance Tests` {

    // MARK: - Insert Performance

    @Test
    func `Insert 10,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        // Insert root
        positions.append(try tree.insert(0, at: .root))

        // Build complete binary tree
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        #expect(tree.count == 10_000)
    }

    @Test
    func `Insert 50,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(50_000)

        positions.append(try tree.insert(0, at: .root))

        for i in 1..<50_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        #expect(tree.count == 50_000)
    }

    // MARK: - Navigation Performance

    @Test
    func `Navigate 100,000 positions`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(1_000)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<1_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        // Navigate many times
        var navigationCount = 0
        for _ in 0..<100 {
            for pos in positions {
                _ = tree.left(of: pos)
                _ = tree.right(of: pos)
                _ = tree.parent(of: pos)
                navigationCount += 3
            }
        }

        #expect(navigationCount == 300_000)
    }

    // MARK: - Traversal Performance

    @Test
    func `Pre-order traversal 10,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        var count = 0
        tree.forEach.preOrder { _ in count += 1 }
        #expect(count == 10_000)
    }

    @Test
    func `In-order traversal 10,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        var count = 0
        tree.forEach.inOrder { _ in count += 1 }
        #expect(count == 10_000)
    }

    @Test
    func `Post-order traversal 10,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        var count = 0
        tree.forEach.postOrder { _ in count += 1 }
        #expect(count == 10_000)
    }

    @Test
    func `Level-order traversal 10,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        var count = 0
        tree.forEach.levelOrder { _ in count += 1 }
        #expect(count == 10_000)
    }

    // MARK: - Remove/Clear Performance

    @Test
    func `Remove subtree 5,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        // Remove left subtree (roughly half the tree)
        let leftChild = tree.left(of: positions[0])!
        try tree.removeSubtree(at: leftChild)

        #expect(tree.count < 10_000)
    }

    @Test
    func `Clear 10,000 nodes`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        tree.clear()
        #expect(tree.isEmpty)
    }

    // MARK: - CoW Performance

    @Test
    func `Copy-on-write with 10,000 nodes`() throws {
        var tree1 = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(10_000)

        positions.append(try tree1.insert(0, at: .root))
        for i in 1..<10_000 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree1.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree1.insert(i, at: .right(of: parent)))
            }
        }

        // Copy (should be O(1) - just reference count bump)
        var tree2 = tree1

        // Find a leaf node (last position in our array is a leaf)
        let leafPosition = positions.last!

        // Mutate tree2 (triggers actual copy)
        _ = try tree2.insert(99999, at: .left(of: leafPosition))

        #expect(tree1.count == 10_000)
        #expect(tree2.count == 10_001)
    }

    // MARK: - Memory Layout Verification

    @Test
    func `Memory layout sizes`() {
        // The per-node arena slot is now a tree-core-internal detail (`__TreeNode`):
        // the public layout facts are the position and the tree handle (a `Shared`
        // CoW box pointer + the root handle — the node payload lives in the arena).
        let positionSize = MemoryLayout<Tree<Int>.Position>.size
        let treeSize = MemoryLayout<Tree<Int>.N<2>>.size

        // Position should be compact (index + token).
        #expect(positionSize <= 16)  // Int + UInt32 + padding

        // The tree handle is a refcounted box pointer plus the root handle.
        #expect(treeSize <= 64)

        // Print for manual inspection.
        print("Position size: \(positionSize) bytes")
        print("Tree handle size: \(treeSize) bytes")
        print("Position stride: \(MemoryLayout<Tree<Int>.Position>.stride) bytes")
        print("Tree handle stride: \(MemoryLayout<Tree<Int>.N<2>>.stride) bytes")
    }

    // MARK: - Token Validation Performance

    @Test
    func `Token validation 100,000 operations`() throws {
        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(100)

        positions.append(try tree.insert(0, at: .root))
        for i in 1..<100 {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        // Perform many peek operations (each validates token)
        var sum = 0
        for _ in 0..<1_000 {
            for pos in positions {
                if let value = tree.peek(at: pos) {
                    sum += value
                }
            }
        }

        #expect(sum > 0)
    }

    // MARK: - Deep Tree Performance

    @Test
    func `Deep tree (1,000 levels left-only)`() throws {
        var tree = Tree<Int>.Binary()

        var current = try tree.insert(0, at: .root)
        for i in 1..<1_000 {
            current = try tree.insert(i, at: .left(of: current))
        }

        #expect(tree.count == 1_000)
        // Height is now iterative - should not stack overflow
        #expect(tree.height == 999)

        // Note: forEach.postOrder is iterative (deep-tree safe); skip on deep trees here
        // Clear is iterative and should work
        tree.clear()
        #expect(tree.isEmpty)
    }

    @Test
    func `Deep tree (5,000 levels) - height and clear`() throws {
        var tree = Tree<Int>.Binary()

        var current = try tree.insert(0, at: .root)
        for i in 1..<5_000 {
            current = try tree.insert(i, at: .left(of: current))
        }

        #expect(tree.count == 5_000)
        // Height is now iterative - should not stack overflow even on very deep trees
        #expect(tree.height == 4_999)

        // Clear should not stack overflow due to iterative implementation
        tree.clear()
        #expect(tree.isEmpty)
    }
}

// MARK: - Performance Stats

@Suite(.serialized)
struct `Tree Binary Stats Tests` {

    // MARK: - Memory Layout

    @Test
    func `Memory layout report`() {
        print("=== Memory Layout ===")

        // The per-node arena slot (element + sparse `InlineArray<n, Handle?>` links +
        // parent handle) is now a tree-core-internal detail (`__TreeNode`), not a
        // public type. The public layout facts are the position and the tree handle
        // (a `Shared` CoW box pointer + the root handle — independent of arity and
        // element, which live in the arena).
        print("Tree<Int>.Position: size=\(MemoryLayout<Tree<Int>.Position>.size) stride=\(MemoryLayout<Tree<Int>.Position>.stride) align=\(MemoryLayout<Tree<Int>.Position>.alignment)")
        print("Tree<Int>.N<2> (handle): size=\(MemoryLayout<Tree<Int>.N<2>>.size) stride=\(MemoryLayout<Tree<Int>.N<2>>.stride)")
        print("Store.Generational.Handle: size=\(MemoryLayout<Store.Generational.Handle>.size) stride=\(MemoryLayout<Store.Generational.Handle>.stride)")

        // Column overhead post-Round-M: the generational column's fused parity-token
        // ledger (ONE Int plane: token = generation<<1 | occupied) and NO tree-side
        // decode table (B2 — positions reconstruct handles from the ledger via
        // handle(at:); the former ~16-24 B/slot table is deleted).
        let retiredSideTable = MemoryLayout<Store.Generational.Handle?>.stride
        print("Retired position side table would have been: \(retiredSideTable) bytes/slot")
    }

    // MARK: - Arena Growth

    //    @Test("Arena growth pattern - doubling")
    //    func arenaGrowthPattern() throws {
    //        var tree = Tree<Int>.Binary()
    //        var positions: [Tree<Int>.Position] = []
    //        positions.reserveCapacity(10_000)
    //
    //        print("=== Arena Growth Pattern (Tree.N growable) ===")
    //        print("nodes | occupied | highWater | capacity | free-list | utilization")
    //        print("------+----------+-----------+----------+-----------+------------")
    //
    //        func logArenaState(_ tree: Tree<Int>.N<2>, label: Int) {
    //            let h = tree._arena.header
    //            (dead/disabled debug code below — inert text, not compiled)
    //            swiftlint:disable no_int_bitpattern_arithmetic
    //            let occ = Int(bitPattern: h.occupied)
    //            let hw = Int(bitPattern: h.highWater)
    //            let cap = Int(bitPattern: h.capacity)
    //            swiftlint:enable no_int_bitpattern_arithmetic
    //            let freeCount = hw - occ
    //            let util = cap > 0 ? String(format: "%.1f%%", Double(occ) / Double(cap) * 100) : "n/a"
    //            print(String(format: "%5d | %8d | %9d | %8d | %9d | %@", label, occ, hw, cap, freeCount, util))
    //        }
    //
    //        logArenaState(tree, label: 0)
    //        positions.append(try tree.insert(0, at: .root))
    //        logArenaState(tree, label: 1)
    //
    //        for i in 1..<10_000 {
    //            let parentIndex = (i - 1) / 2
    //            let parent = positions[parentIndex]
    //            if i % 2 == 1 {
    //                positions.append(try tree.insert(i, at: .left(of: parent)))
    //            } else {
    //                positions.append(try tree.insert(i, at: .right(of: parent)))
    //            }
    //
    //            if i == 10 || i == 100 || i == 500 || i == 1_000
    //                || i == 2_000 || i == 5_000 || i == 9_999 {
    //                logArenaState(tree, label: i + 1)
    //            }
    //        }
    //    }
    //
    //    @Test("Arena growth with pre-reserved capacity")
    //    func arenaPreReserved() throws {
    //        var tree = try Tree<Int>.Binary(minimumCapacity: 10_000)
    //        var positions: [Tree<Int>.Position] = []
    //        positions.reserveCapacity(10_000)
    //
    //        print("=== Arena with Pre-Reserved Capacity (10,000) ===")
    //
    //        let h0 = tree._arena.header
    //        print("Before inserts: occupied=\(Int(bitPattern: h0.occupied)) capacity=\(Int(bitPattern: h0.capacity))")
    //
    //        positions.append(try tree.insert(0, at: .root))
    //        for i in 1..<10_000 {
    //            let parentIndex = (i - 1) / 2
    //            let parent = positions[parentIndex]
    //            if i % 2 == 1 {
    //                positions.append(try tree.insert(i, at: .left(of: parent)))
    //            } else {
    //                positions.append(try tree.insert(i, at: .right(of: parent)))
    //            }
    //        }
    //
    //        let h1 = tree._arena.header
    //        print("After 10,000 inserts: occupied=\(Int(bitPattern: h1.occupied)) capacity=\(Int(bitPattern: h1.capacity))")
    //        print("Grew? \(Int(bitPattern: h1.capacity) != Int(bitPattern: h0.capacity))")
    //    }

    // MARK: - Free-List Behavior

    //    @Test("Free-list after insert/remove cycles")
    //    func freeListBehavior() throws {
    //        var tree = Tree<Int>.Binary()
    //        var positions: [Tree<Int>.Position] = []
    //        positions.reserveCapacity(100)
    //
    //        print("=== Free-List Behavior ===")
    //
    //        // Build a tree with 100 nodes
    //        positions.append(try tree.insert(0, at: .root))
    //        for i in 1..<100 {
    //            let parentIndex = (i - 1) / 2
    //            let parent = positions[parentIndex]
    //            if i % 2 == 1 {
    //                positions.append(try tree.insert(i, at: .left(of: parent)))
    //            } else {
    //                positions.append(try tree.insert(i, at: .right(of: parent)))
    //            }
    //        }
    //
    //        let hBefore = tree._arena.header
    //        print("After 100 inserts: occupied=\(Int(bitPattern: hBefore.occupied)) highWater=\(Int(bitPattern: hBefore.highWater)) freeHead=\(hBefore.freeHead) hasFree=\(hBefore.hasFree)")
    //
    //        // Remove leaf nodes (every node at index 50..99 that has no children)
    //        var removedCount = 0
    //        for i in stride(from: 99, through: 50, by: -1) {
    //            if tree.isLeaf(positions[i]) {
    //                _ = try tree.remove(at: positions[i])
    //                removedCount += 1
    //            }
    //        }
    //
    //        let hAfter = tree._arena.header
    //        print("After removing \(removedCount) leaves: occupied=\(Int(bitPattern: hAfter.occupied)) highWater=\(Int(bitPattern: hAfter.highWater)) freeHead=\(hAfter.freeHead) hasFree=\(hAfter.hasFree)")
    //        (dead/disabled debug code — inert text, not compiled)
    //        swiftlint:disable:next no_int_bitpattern_arithmetic
    //        print("Free slots on list: \(Int(bitPattern: hAfter.highWater) - Int(bitPattern: hAfter.occupied))")
    //
    //        // Re-insert into freed slots
    //        let root = tree.root!
    //        let leftChild = tree.left(of: root)!
    //        var reinserted = 0
    //        for i in 0..<removedCount {
    //            if tree.isLeaf(leftChild) {
    //                _ = try tree.insert(1000 + i, at: .left(of: leftChild))
    //                reinserted += 1
    //                break
    //            }
    //        }
    //
    //        let hReinsert = tree._arena.header
    //        print("After \(reinserted) re-insert: occupied=\(Int(bitPattern: hReinsert.occupied)) highWater=\(Int(bitPattern: hReinsert.highWater)) (should not grow)")
    //        print("Slot reuse: highWater unchanged = \(Int(bitPattern: hReinsert.highWater) == Int(bitPattern: hAfter.highWater))")
    //    }

    // MARK: - Timed Operations

    @Test
    func `Timed insert - growable vs bounded vs pre-reserved`() throws {
        let nodeCount = 10_000
        let clock = ContinuousClock()

        // Growable (no pre-reserve)
        let growableTime = try clock.measure {
            var tree = Tree<Int>.Binary()
            var positions: [Tree<Int>.Position] = []
            positions.reserveCapacity(nodeCount)
            positions.append(try tree.insert(0, at: .root))
            for i in 1..<nodeCount {
                let parentIndex = (i - 1) / 2
                let parent = positions[parentIndex]
                if i % 2 == 1 {
                    positions.append(try tree.insert(i, at: .left(of: parent)))
                } else {
                    positions.append(try tree.insert(i, at: .right(of: parent)))
                }
            }
        }

        // Pre-reserved
        let preReservedTime = try clock.measure {
            var tree = Tree<Int>.Binary(minimumCapacity: 10_000)
            var positions: [Tree<Int>.Position] = []
            positions.reserveCapacity(nodeCount)
            positions.append(try tree.insert(0, at: .root))
            for i in 1..<nodeCount {
                let parentIndex = (i - 1) / 2
                let parent = positions[parentIndex]
                if i % 2 == 1 {
                    positions.append(try tree.insert(i, at: .left(of: parent)))
                } else {
                    positions.append(try tree.insert(i, at: .right(of: parent)))
                }
            }
        }

        print("=== Timed Insert (\(nodeCount) nodes) ===")
        print("Growable (no reserve): \(growableTime)")
        print("Pre-reserved:          \(preReservedTime)")
    }

    @Test
    func `Timed traversal comparison`() throws {
        let nodeCount = 10_000
        let clock = ContinuousClock()

        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(nodeCount)
        positions.append(try tree.insert(0, at: .root))
        for i in 1..<nodeCount {
            let parentIndex = (i - 1) / 2
            let parent = positions[parentIndex]
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: parent)))
            } else {
                positions.append(try tree.insert(i, at: .right(of: parent)))
            }
        }

        var count = 0

        let preOrderTime = clock.measure {
            count = 0
            tree.forEach.preOrder { _ in count += 1 }
        }

        let inOrderTime = clock.measure {
            count = 0
            tree.forEach.inOrder { _ in count += 1 }
        }

        let postOrderTime = clock.measure {
            count = 0
            tree.forEach.postOrder { _ in count += 1 }
        }

        let levelOrderTime = clock.measure {
            count = 0
            tree.forEach.levelOrder { _ in count += 1 }
        }

        print("=== Timed Traversal (\(nodeCount) nodes, complete binary tree) ===")
        print("Pre-order:   \(preOrderTime)")
        print("In-order:    \(inOrderTime)")
        print("Post-order:  \(postOrderTime)")
        print("Level-order: \(levelOrderTime)")
        _ = count
    }

    @Test
    func `Timed traversal - degenerate left-chain`() throws {
        let nodeCount = 5_000
        let clock = ContinuousClock()

        var tree = Tree<Int>.Binary()
        var current = try tree.insert(0, at: .root)
        for i in 1..<nodeCount {
            current = try tree.insert(i, at: .left(of: current))
        }

        var count = 0

        let preOrderTime = clock.measure {
            count = 0
            tree.forEach.preOrder { _ in count += 1 }
        }

        let inOrderTime = clock.measure {
            count = 0
            tree.forEach.inOrder { _ in count += 1 }
        }

        let postOrderTime = clock.measure {
            count = 0
            tree.forEach.postOrder { _ in count += 1 }
        }

        let levelOrderTime = clock.measure {
            count = 0
            tree.forEach.levelOrder { _ in count += 1 }
        }

        print("=== Timed Traversal (\(nodeCount) nodes, left-chain / depth=\(nodeCount - 1)) ===")
        print("Pre-order:   \(preOrderTime)")
        print("In-order:    \(inOrderTime)")
        print("Post-order:  \(postOrderTime)")
        print("Level-order: \(levelOrderTime)")
        _ = count
    }

    // MARK: - Variant Comparison

    @Test
    func `Variant comparison - insert 128 nodes`() throws {
        let nodeCount = 128
        let clock = ContinuousClock()

        // Tree.N (growable)
        let growableTime = try clock.measure {
            var tree = Tree<Int>.Binary()
            var positions: [Tree<Int>.Position] = []
            positions.reserveCapacity(nodeCount)
            positions.append(try tree.insert(0, at: .root))
            for i in 1..<nodeCount {
                let p = (i - 1) / 2
                if i % 2 == 1 {
                    positions.append(try tree.insert(i, at: .left(of: positions[p])))
                } else {
                    positions.append(try tree.insert(i, at: .right(of: positions[p])))
                }
            }
        }

        print("=== Variant Comparison (\(nodeCount) node complete binary tree) ===")
        print("Tree.N (growable):   \(growableTime)")
    }

    // MARK: - CoW Cost

    @Test
    func `CoW copy and mutation cost`() throws {
        let nodeCount = 10_000
        let clock = ContinuousClock()

        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(nodeCount)
        positions.append(try tree.insert(0, at: .root))
        for i in 1..<nodeCount {
            let p = (i - 1) / 2
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: positions[p])))
            } else {
                positions.append(try tree.insert(i, at: .right(of: positions[p])))
            }
        }

        // Shallow copy (reference count bump)
        var tree2: Tree<Int>.Binary!
        let copyTime = clock.measure {
            tree2 = tree
        }

        // First mutation triggers deep copy
        let leafPos = positions.last!
        let firstMutationTime = try clock.measure {
            _ = try tree2.insert(99999, at: .left(of: leafPos))
        }

        // Subsequent mutation (no copy)
        let leaf2 = tree2.left(of: leafPos)!
        let subsequentMutationTime = try clock.measure {
            _ = try tree2.insert(99998, at: .left(of: leaf2))
        }

        print("=== CoW Cost (\(nodeCount) nodes) ===")
        print("Shallow copy (ref-count bump): \(copyTime)")
        print("First mutation (deep copy):    \(firstMutationTime)")
        print("Subsequent mutation (no copy): \(subsequentMutationTime)")

        #expect(tree.count == 10_000)
        #expect(tree2.count == 10_002)
    }

    // MARK: - Small Spill

    //    @Test("Small tree spill point analysis")
    //    func smallSpillAnalysis() throws {
    //        let inlineCapacities = [4, 8, 16, 32, 64]
    //        let clock = ContinuousClock()
    //
    //        print("=== Small Tree Spill Analysis ===")
    //        print("inline cap | spill after | time to spill | time after spill (next 100)")
    //        print("-----------+-------------+---------------+----------------------------")
    //
    //        // Inline<4>
    //        do {
    //            var tree = Tree<Int>.Binary.Small<4>()
    //            var positions: [Tree<Int>.Position] = []
    //            var spilledAt = -1
    //            let spillTime = try clock.measure {
    //                positions.append(try tree.insert(0, at: .root))
    //                for i in 1..<200 {
    //                    let p = (i - 1) / 2
    //                    if i % 2 == 1 {
    //                        positions.append(try tree.insert(i, at: .left(of: positions[p])))
    //                    } else {
    //                        positions.append(try tree.insert(i, at: .right(of: positions[p])))
    //                    }
    //                    if spilledAt < 0 && tree.isSpilled { spilledAt = i + 1 }
    //                }
    //            }
    //            print(String(format: "%10d | %11d | %@ | (included)", 4, spilledAt, "\(spillTime)"))
    //        }
    //
    //        // Inline<8>
    //        do {
    //            var tree = Tree<Int>.Binary.Small<8>()
    //            var positions: [Tree<Int>.Position] = []
    //            var spilledAt = -1
    //            let spillTime = try clock.measure {
    //                positions.append(try tree.insert(0, at: .root))
    //                for i in 1..<200 {
    //                    let p = (i - 1) / 2
    //                    if i % 2 == 1 {
    //                        positions.append(try tree.insert(i, at: .left(of: positions[p])))
    //                    } else {
    //                        positions.append(try tree.insert(i, at: .right(of: positions[p])))
    //                    }
    //                    if spilledAt < 0 && tree.isSpilled { spilledAt = i + 1 }
    //                }
    //            }
    //            print(String(format: "%10d | %11d | %@ | (included)", 8, spilledAt, "\(spillTime)"))
    //        }
    //
    //        // Inline<16>
    //        do {
    //            var tree = Tree<Int>.Binary.Small<16>()
    //            var positions: [Tree<Int>.Position] = []
    //            var spilledAt = -1
    //            let spillTime = try clock.measure {
    //                positions.append(try tree.insert(0, at: .root))
    //                for i in 1..<200 {
    //                    let p = (i - 1) / 2
    //                    if i % 2 == 1 {
    //                        positions.append(try tree.insert(i, at: .left(of: positions[p])))
    //                    } else {
    //                        positions.append(try tree.insert(i, at: .right(of: positions[p])))
    //                    }
    //                    if spilledAt < 0 && tree.isSpilled { spilledAt = i + 1 }
    //                }
    //            }
    //            print(String(format: "%10d | %11d | %@ | (included)", 16, spilledAt, "\(spillTime)"))
    //        }
    //
    //        // Inline<32>
    //        do {
    //            var tree = Tree<Int>.Binary.Small<32>()
    //            var positions: [Tree<Int>.Position] = []
    //            var spilledAt = -1
    //            let spillTime = try clock.measure {
    //                positions.append(try tree.insert(0, at: .root))
    //                for i in 1..<200 {
    //                    let p = (i - 1) / 2
    //                    if i % 2 == 1 {
    //                        positions.append(try tree.insert(i, at: .left(of: positions[p])))
    //                    } else {
    //                        positions.append(try tree.insert(i, at: .right(of: positions[p])))
    //                    }
    //                    if spilledAt < 0 && tree.isSpilled { spilledAt = i + 1 }
    //                }
    //            }
    //            print(String(format: "%10d | %11d | %@ | (included)", 32, spilledAt, "\(spillTime)"))
    //        }
    //
    //        // Inline<64>
    //        do {
    //            var tree = Tree<Int>.Binary.Small<64>()
    //            var positions: [Tree<Int>.Position] = []
    //            var spilledAt = -1
    //            let spillTime = try clock.measure {
    //                positions.append(try tree.insert(0, at: .root))
    //                for i in 1..<200 {
    //                    let p = (i - 1) / 2
    //                    if i % 2 == 1 {
    //                        positions.append(try tree.insert(i, at: .left(of: positions[p])))
    //                    } else {
    //                        positions.append(try tree.insert(i, at: .right(of: positions[p])))
    //                    }
    //                    if spilledAt < 0 && tree.isSpilled { spilledAt = i + 1 }
    //                }
    //            }
    //            print(String(format: "%10d | %11d | %@ | (included)", 64, spilledAt, "\(spillTime)"))
    //        }
    //
    //        _ = inlineCapacities
    //    }

    // MARK: - Navigation Cost

    @Test
    func `Navigation cost - pointer chase analysis`() throws {
        let nodeCount = 10_000
        let iterations = 100
        let clock = ContinuousClock()

        var tree = Tree<Int>.Binary()
        var positions: [Tree<Int>.Position] = []
        positions.reserveCapacity(nodeCount)
        positions.append(try tree.insert(0, at: .root))
        for i in 1..<nodeCount {
            let p = (i - 1) / 2
            if i % 2 == 1 {
                positions.append(try tree.insert(i, at: .left(of: positions[p])))
            } else {
                positions.append(try tree.insert(i, at: .right(of: positions[p])))
            }
        }

        // Random access: peek at positions in array order (sequential slot access)
        var sum = 0
        _ = clock.measure {
            for _ in 0..<iterations {
                for pos in positions {
                    sum += tree.peek(at: pos) ?? 0
                }
            }
        }

        // Walk root-to-leaf: chase parent/child pointers
        var walkCount = 0
        _ = clock.measure {
            for _ in 0..<iterations {
                var pos = tree.root!
                while true {
                    walkCount += 1
                    if let l = tree.left(of: pos) {
                        pos = l
                    } else if let r = tree.right(of: pos) {
                        pos = r
                    } else {
                        break
                    }
                }
            }
        }

        // let seqNs = Double(sequentialTime.components.attoseconds) / 1e9
        // let walkNs = Double(walkTime.components.attoseconds) / 1e9
        // let totalSeqOps = nodeCount * iterations
        // let nsPerSeqOp = seqNs / Double(totalSeqOps)
        // let nsPerWalkOp = walkNs / Double(walkCount)

        print("=== Navigation Cost (\(nodeCount) nodes) ===")
        //        print("Sequential peek (\(totalSeqOps) ops): \(sequentialTime)  (\(String(format: "%.1f", nsPerSeqOp)) ns/op)")
        //        print("Root-to-leaf walk (\(walkCount) ops): \(walkTime)  (\(String(format: "%.1f", nsPerWalkOp)) ns/op)")
        _ = sum
    }

    // MARK: - Arity Comparison

    //    @Test("N-ary tree arity comparison")
    //    func arityComparison() throws {
    //        let nodeCount = 5_000
    //        let clock = ContinuousClock()
    //
    //        // Binary (n=2)
    //        let binaryTime = try clock.measure {
    //            var tree = Tree<Int>.N<2>()
    //            var positions: [Tree<Int>.Position] = []
    //            positions.reserveCapacity(nodeCount)
    //            positions.append(try tree.insert(0, at: .root))
    //            for i in 1..<nodeCount {
    //                let p = (i - 1) / 2
    //                let slot = Tree<Int>.N<2>.ChildSlot(i % 2 == 1 ? 0 : 1)
    //                positions.append(try tree.insert(i, at: .child(of: positions[p], slot: slot)))
    //            }
    //        }
    //
    //        // Quad (n=4)
    //        let quadTime = try clock.measure {
    //            var tree = Tree<Int>.N<4>()
    //            var positions: [Tree<Int>.Position] = []
    //            positions.reserveCapacity(nodeCount)
    //            positions.append(try tree.insert(0, at: .root))
    //            for i in 1..<nodeCount {
    //                let p = (i - 1) / 4
    //                let slot = Tree<Int>.N<4>.ChildSlot((i - 1) % 4)
    //                positions.append(try tree.insert(i, at: .child(of: positions[p], slot: slot)))
    //            }
    //        }
    //
    //        // Octal (n=8)
    //        let octalTime = try clock.measure {
    //            var tree = Tree<Int>.N<8>()
    //            var positions: [Tree<Int>.Position] = []
    //            positions.reserveCapacity(nodeCount)
    //            positions.append(try tree.insert(0, at: .root))
    //            for i in 1..<nodeCount {
    //                let p = (i - 1) / 8
    //                let slot = Tree<Int>.N<8>.ChildSlot((i - 1) % 8)
    //                positions.append(try tree.insert(i, at: .child(of: positions[p], slot: slot)))
    //            }
    //        }
    //
    //        print("=== Arity Comparison (\(nodeCount) nodes) ===")
    //        print("Binary (n=2): \(binaryTime)  node=\(MemoryLayout<Tree<Int>.N<2>.Node>.stride)B")
    //        print("Quad   (n=4): \(quadTime)  node=\(MemoryLayout<Tree<Int>.N<4>.Node>.stride)B")
    //        print("Octal  (n=8): \(octalTime)  node=\(MemoryLayout<Tree<Int>.N<8>.Node>.stride)B")
    //    }

    // MARK: - Remove + Re-insert Throughput

    //    @Test("Churn: interleaved remove and re-insert")
    //    func churnTest() throws {
    //        let nodeCount = 5_000
    //        let churnRounds = 10
    //        let clock = ContinuousClock()
    //
    //        var tree = Tree<Int>.Binary()
    //        var positions: [Tree<Int>.Position] = []
    //        positions.reserveCapacity(nodeCount)
    //        positions.append(try tree.insert(0, at: .root))
    //        for i in 1..<nodeCount {
    //            let p = (i - 1) / 2
    //            if i % 2 == 1 {
    //                positions.append(try tree.insert(i, at: .left(of: positions[p])))
    //            } else {
    //                positions.append(try tree.insert(i, at: .right(of: positions[p])))
    //            }
    //        }
    //
    //        let hBeforeChurn = tree._arena.header
    //        print("=== Churn Test (\(nodeCount) nodes, \(churnRounds) rounds) ===")
    //        print("Before churn: occupied=\(Int(bitPattern: hBeforeChurn.occupied)) highWater=\(Int(bitPattern: hBeforeChurn.highWater)) capacity=\(Int(bitPattern: hBeforeChurn.capacity))")
    //
    //        var totalRemoved = 0
    //        var totalInserted = 0
    //
    //        let churnTime = try clock.measure {
    //            for round in 0..<churnRounds {
    //                // Remove all leaves at depth >= log2(nodeCount) - 2
    //                var removed: [(parent: Tree<Int>.Position, slot: Int)] = []
    //                for i in ((nodeCount / 2)..<positions.count).reversed() {
    //                    if tree.isLeaf(positions[i]) {
    //                        let parentPos = tree.parent(of: positions[i])!
    //                        let wasLeft = tree.left(of: parentPos) != nil
    //                            && tree.left(of: parentPos)!.index == positions[i].index
    //                        _ = try tree.remove(at: positions[i])
    //                        removed.append((parent: parentPos, slot: wasLeft ? 0 : 1))
    //                        totalRemoved += 1
    //                        if removed.count >= 500 { break }
    //                    }
    //                }
    //
    //                // Re-insert at freed parents
    //                for (parent, slot) in removed {
    //                    let childSlot = Tree<Int>.N<2>.ChildSlot(slot)
    //                    let newPos = try tree.insert(10_000 + round * 1000 + totalInserted, at: .child(of: parent, slot: childSlot))
    //                    totalInserted += 1
    //                    // Update position for future rounds
    //                    if let idx = positions.firstIndex(where: { $0.index == parent.index }) {
    //                        if idx * 2 + (slot == 0 ? 1 : 2) < positions.count {
    //                            positions[idx * 2 + (slot == 0 ? 1 : 2)] = newPos
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //
    //        let hAfterChurn = tree._arena.header
    //        print("After churn: occupied=\(Int(bitPattern: hAfterChurn.occupied)) highWater=\(Int(bitPattern: hAfterChurn.highWater)) capacity=\(Int(bitPattern: hAfterChurn.capacity))")
    //        print("Removed: \(totalRemoved) Inserted: \(totalInserted)")
    //        (dead/disabled debug code — inert text, not compiled)
    //        swiftlint:disable:next no_int_bitpattern_arithmetic
    //        print("HighWater grew by: \(Int(bitPattern: hAfterChurn.highWater) - Int(bitPattern: hBeforeChurn.highWater)) (0 = perfect slot reuse)")
    //        print("Total churn time: \(churnTime)")
    //    }
}
