import Array_Primitives
import Sequence_Primitives
import Synchronization
import Testing
import Tree_N_Primitives_Test_Support

@testable import Tree_N_Primitives

private func expectEqual(_ array: borrowing [Int], _ expected: Int...) {
    var index = 0
    array.forEach { element in
        guard index < expected.count else {
            Issue.record("Array has more elements than expected")
            return
        }
        #expect(element == expected[index])
        index += 1
    }
    #expect(index == expected.count, "Array has \(index) elements, expected \(expected.count)")
}

@Suite
struct `Tree.N<2>` {

    @Test
    func `Empty tree`() {
        let tree = Tree<Int>.N<2>()
        #expect(tree.isEmpty)
        #expect(tree.count == 0)
        #expect(tree.root == nil)
        #expect(tree.height == nil)
    }

    @Test
    func `Insert root`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(42, at: .root)

        #expect(!tree.isEmpty)
        #expect(tree.count == 1)
        #expect(tree.root != nil)
        #expect(tree.root == root)
        #expect(tree.peek(at: root) == 42)
        #expect(tree.height == 0)
    }

    @Test
    func `Insert children`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        let right = try tree.insert(3, at: .right(of: root))

        #expect(tree.count == 3)
        #expect(tree.left(of: root) == left)
        #expect(tree.right(of: root) == right)
        #expect(tree.parent(of: left) == root)
        #expect(tree.parent(of: right) == root)
        #expect(tree.isLeaf(root) == false)
        #expect(tree.isLeaf(left) == true)
        #expect(tree.isLeaf(right) == true)
        #expect(tree.height == 1)
    }

    @Test
    func `Insert throws on occupied root`() throws {
        var tree = Tree<Int>.N<2>()
        _ = try tree.insert(1, at: .root)

        #expect(throws: __TreeError.rootOccupied) {
            try tree.insert(2, at: .root)
        }
    }

    @Test
    func `Insert throws on occupied child`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        _ = try tree.insert(2, at: .left(of: root))

        #expect(throws: __TreeError.slotOccupied) {
            try tree.insert(3, at: .left(of: root))
        }
    }

    @Test
    func `Remove leaf`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))

        let removed = try tree.remove(at: left)
        #expect(removed == 2)
        #expect(tree.count == 1)
        #expect(tree.left(of: root) == nil)
    }

    @Test
    func `Remove throws on non-leaf`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        _ = try tree.insert(2, at: .left(of: root))

        #expect(throws: __TreeError.cannotRemoveNonLeaf) {
            try tree.remove(at: root)
        }
    }

    @Test
    func `Remove subtree`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))
        _ = try tree.insert(3, at: .right(of: root))

        #expect(tree.count == 5)

        try tree.removeSubtree(at: left)
        #expect(tree.count == 2)
        #expect(tree.left(of: root) == nil)
    }

    @Test
    func `Clear tree`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        _ = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))

        tree.clear()
        #expect(tree.isEmpty)
        #expect(tree.count == 0)
        #expect(tree.root == nil)
    }

    @Test
    func `Pre-order traversal`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))
        _ = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))

        var result = [Int]()
        tree.forEach.preOrder { result.append($0) }
        expectEqual(result, 1, 2, 4, 5, 3)
    }

    @Test
    func `In-order traversal`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))
        _ = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))

        var result = [Int]()
        tree.forEach.inOrder { result.append($0) }
        expectEqual(result, 4, 2, 5, 1, 3)
    }

    @Test
    func `Post-order traversal`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))
        _ = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))

        var result = [Int]()
        tree.forEach.postOrder { result.append($0) }
        expectEqual(result, 4, 5, 2, 3, 1)
    }

    @Test
    func `Level-order traversal`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))
        _ = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))

        var result = [Int]()
        tree.forEach.levelOrder { result.append($0) }
        expectEqual(result, 1, 2, 3, 4, 5)
    }

    @Test
    func `Traversal sequences`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))
        _ = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))

        expectEqual(tree.preOrder.collect(), 1, 2, 4, 5, 3)
        expectEqual(tree.inOrder.collect(), 4, 2, 5, 1, 3)
        expectEqual(tree.postOrder.collect(), 4, 5, 2, 3, 1)
        expectEqual(tree.levelOrder.collect(), 1, 2, 3, 4, 5)
    }

    @Test
    func `Height calculation`() throws {
        var tree = Tree<Int>.N<2>()
        #expect(tree.height == nil)

        let root = try tree.insert(1, at: .root)
        #expect(tree.height == 0)

        let left = try tree.insert(2, at: .left(of: root))
        #expect(tree.height == 1)

        _ = try tree.insert(4, at: .left(of: left))
        #expect(tree.height == 2)
    }

    @Test
    func `Capacity growth`() throws {
        var tree = Tree<Int>.N<2>()

        var positions: [Tree<Int>.Position] = []
        positions.append(try tree.insert(1, at: .root))

        for i in 0..<7 {
            if i * 2 + 1 < 15 {
                positions.append(try tree.insert(i * 2 + 2, at: .left(of: positions[i])))
            }
            if i * 2 + 2 < 15 {
                positions.append(try tree.insert(i * 2 + 3, at: .right(of: positions[i])))
            }
        }

        #expect(tree.count == 15)
    }
}

@Suite
struct `Tree.N<2>.NonCopyable` {

    struct Token: ~Copyable {
        let value: Int
        let tracker: DeinitTracker

        init(_ value: Int, tracker: DeinitTracker) {
            self.value = value
            self.tracker = tracker
        }

        deinit {
            tracker.record(value)
        }
    }

    final class DeinitTracker: Sendable {
        private let _order: Mutex<[Int]> = Mutex([])
    }

    @Test
    func `NonCopyable insert and peek`() throws {
        let tracker = DeinitTracker()
        var tree = Tree<Token>.N<2>()

        let root = try tree.insert(Token(1, tracker: tracker), at: .root)
        _ = try tree.insert(Token(2, tracker: tracker), at: .left(of: root))

        #expect(tree.count == 2)

        tree.peek(at: root) { token in
            #expect(token.value == 1)
        }
    }

    @Test
    func `NonCopyable deinit order - slot order`() throws {
        let tracker = DeinitTracker()

        do {
            var tree = Tree<Token>.N<2>()
            let root = try tree.insert(Token(1, tracker: tracker), at: .root)
            let left = try tree.insert(Token(2, tracker: tracker), at: .left(of: root))
            _ = try tree.insert(Token(3, tracker: tracker), at: .right(of: root))
            _ = try tree.insert(Token(4, tracker: tracker), at: .left(of: left))
            _ = try tree.insert(Token(5, tracker: tracker), at: .right(of: left))
        }

        #expect(tracker.order == [1, 2, 3, 4, 5])
    }

    @Test
    func `NonCopyable forEach`() throws {
        let tracker = DeinitTracker()
        var tree = Tree<Token>.N<2>()

        let root = try tree.insert(Token(1, tracker: tracker), at: .root)
        _ = try tree.insert(Token(2, tracker: tracker), at: .left(of: root))
        _ = try tree.insert(Token(3, tracker: tracker), at: .right(of: root))

        var values = [Int]()
        tree.forEach.preOrder { token in
            values.append(token.value)
        }
        expectEqual(values, 1, 2, 3)
    }
}

extension `Tree.N<2>.NonCopyable`.DeinitTracker {
    func record(_ value: Int) {
        _order.withLock { $0.append(value) }
    }

    var order: [Int] {
        _order.withLock { $0 }
    }
}

@Suite
struct `Tree.N<2>.ConditionalCopyable` {

    @Test
    func `Copyable when element is Copyable`() throws {
        var tree1 = Tree<Int>.N<2>()
        let root = try tree1.insert(1, at: .root)
        _ = try tree1.insert(2, at: .left(of: root))

        let tree2 = tree1

        #expect(tree1.count == tree2.count)
    }

    @Test
    func `Copy-on-write behavior`() throws {
        var tree1 = Tree<Int>.N<2>()
        let root = try tree1.insert(1, at: .root)
        _ = try tree1.insert(2, at: .left(of: root))

        var tree2 = tree1

        _ = try tree2.insert(3, at: .right(of: tree2.root!))

        #expect(tree1.count == 2)
        #expect(tree2.count == 3)
    }
}

@Suite
struct `Tree.N<2>.Sendable` {

    func requireSendable<T: Sendable & ~Copyable>(_: borrowing T) {}

    @Test
    func `Sendable when element is Sendable`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(42, at: .root)
        _ = try tree.insert(1, at: .left(of: root))

        requireSendable(tree)
    }

}

@Suite
struct `Tree.N<2>.StalePosition` {

    @Test
    func `Stale position after remove returns nil for navigation`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))

        _ = try tree.remove(at: left)

        #expect(tree.left(of: left) == nil)
        #expect(tree.right(of: left) == nil)
        #expect(tree.parent(of: left) == nil)
        #expect(tree.isLeaf(left) == false)
        #expect(tree.peek(at: left) == nil)
    }

    @Test
    func `Stale position after remove throws on insert`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        _ = try tree.insert(3, at: .right(of: root))

        _ = try tree.remove(at: left)

        #expect(throws: __TreeError.invalidPosition) {
            try tree.insert(4, at: .left(of: left))
        }
        #expect(throws: __TreeError.invalidPosition) {
            try tree.insert(5, at: .right(of: left))
        }
    }

    @Test
    func `Position remains valid after unrelated inserts`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))

        let leftPosition = left

        _ = try tree.insert(3, at: .right(of: root))
        _ = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))

        #expect(tree.peek(at: leftPosition) == 2)
        #expect(tree.parent(of: leftPosition) == root)
        #expect(tree.left(of: leftPosition) != nil)
        #expect(tree.right(of: leftPosition) != nil)
    }

    @Test
    func `Position remains valid after unrelated removes`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))
        let right = try tree.insert(3, at: .right(of: root))
        let leftLeft = try tree.insert(4, at: .left(of: left))
        _ = try tree.insert(5, at: .right(of: left))

        _ = try tree.remove(at: right)
        _ = try tree.remove(at: leftLeft)

        #expect(tree.peek(at: left) == 2)
        #expect(tree.parent(of: left) == root)
    }

    @Test
    func `Position survives CoW copy`() throws {
        var tree1 = Tree<Int>.N<2>()
        let root = try tree1.insert(1, at: .root)
        let left = try tree1.insert(2, at: .left(of: root))

        var tree2 = tree1

        _ = try tree2.insert(3, at: .right(of: tree2.root!))

        #expect(tree1.peek(at: root) == 1)
        #expect(tree1.peek(at: left) == 2)

        #expect(tree2.peek(at: tree2.root!) == 1)
    }

    @Test
    func `Position survives growth reallocation`() throws {
        var tree = Tree<Int>.N<2>()

        let root = try tree.insert(1, at: .root)
        var positions: [Tree<Int>.Position] = [root]

        for i in 0..<20 {
            let parent = positions[i / 2]
            if i % 2 == 0 && tree.left(of: parent) == nil {
                positions.append(try tree.insert(i + 2, at: .left(of: parent)))
            } else if tree.right(of: parent) == nil {
                positions.append(try tree.insert(i + 2, at: .right(of: parent)))
            }
        }

        #expect(tree.peek(at: root) == 1)
        #expect(tree.peek(at: positions[1]) != nil)
    }

    @Test
    func `Removed and reallocated slot invalidates old position`() throws {
        var tree = Tree<Int>.N<2>()
        let root = try tree.insert(1, at: .root)
        let left = try tree.insert(2, at: .left(of: root))

        _ = try tree.remove(at: left)

        let newLeft = try tree.insert(3, at: .left(of: root))

        #expect(tree.peek(at: left) == nil)

        #expect(tree.peek(at: newLeft) == 3)

        #expect(left != newLeft)
    }
}
