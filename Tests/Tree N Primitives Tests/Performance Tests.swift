import Testing
import Tree_N_Primitives_Test_Support

@testable import Buffer_Primitives
@testable import Tree_N_Primitives

@Suite(.serialized)
struct `Tree Binary Performance Tests` {

    @Test
    func `Insert 10,000 nodes`() throws {
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

        var tree2 = tree1

        let leafPosition = positions.last!

        _ = try tree2.insert(99999, at: .left(of: leafPosition))

        #expect(tree1.count == 10_000)
        #expect(tree2.count == 10_001)
    }

    @Test
    func `Memory layout sizes`() {

        let positionSize = MemoryLayout<Tree<Int>.Position>.size
        let treeSize = MemoryLayout<Tree<Int>.N<2>>.size

        #expect(positionSize <= 16)

        #expect(treeSize <= 64)

        print("Position size: \(positionSize) bytes")
        print("Tree handle size: \(treeSize) bytes")
        print("Position stride: \(MemoryLayout<Tree<Int>.Position>.stride) bytes")
        print("Tree handle stride: \(MemoryLayout<Tree<Int>.N<2>>.stride) bytes")
    }

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

    @Test
    func `Deep tree (1,000 levels left-only)`() throws {
        var tree = Tree<Int>.Binary()

        var current = try tree.insert(0, at: .root)
        for i in 1..<1_000 {
            current = try tree.insert(i, at: .left(of: current))
        }

        #expect(tree.count == 1_000)

        #expect(tree.height == 999)

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

        #expect(tree.height == 4_999)

        tree.clear()
        #expect(tree.isEmpty)
    }
}

@Suite(.serialized)
struct `Tree Binary Stats Tests` {

    @Test
    func `Memory layout report`() {
        print("=== Memory Layout ===")

        print(
            "Tree<Int>.Position: size=\(MemoryLayout<Tree<Int>.Position>.size) stride=\(MemoryLayout<Tree<Int>.Position>.stride) align=\(MemoryLayout<Tree<Int>.Position>.alignment)"
        )
        print(
            "Tree<Int>.N<2> (handle): size=\(MemoryLayout<Tree<Int>.N<2>>.size) stride=\(MemoryLayout<Tree<Int>.N<2>>.stride)"
        )
        print(
            "Store.Generational.Handle: size=\(MemoryLayout<Store.Generational.Handle>.size) stride=\(MemoryLayout<Store.Generational.Handle>.stride)"
        )

        let retiredSideTable = MemoryLayout<Store.Generational.Handle?>.stride
        print("Retired position side table would have been: \(retiredSideTable) bytes/slot")
    }

    @Test
    func `Timed insert - growable vs bounded vs pre-reserved`() throws {
        let nodeCount = 10_000
        let clock = ContinuousClock()

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

    @Test
    func `Variant comparison - insert 128 nodes`() throws {
        let nodeCount = 128
        let clock = ContinuousClock()

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

        var tree2: Tree<Int>.Binary!
        let copyTime = clock.measure {
            tree2 = tree
        }

        let leafPos = positions.last!
        let firstMutationTime = try clock.measure {
            _ = try tree2.insert(99999, at: .left(of: leafPos))
        }

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

        var sum = 0
        _ = clock.measure {
            for _ in 0..<iterations {
                for pos in positions {
                    sum += tree.peek(at: pos) ?? 0
                }
            }
        }

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

        print("=== Navigation Cost (\(nodeCount) nodes) ===")

        _ = sum
    }

}
