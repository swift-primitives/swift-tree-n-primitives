import Testing
import Tree_N_Primitives_Test_Support

@testable import Tree_N_Primitives

@Suite
struct `Tree.Binary.Builder` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite struct `Level Order` {}
    @Suite struct `Static Methods` {}
}

extension `Tree.Binary.Builder` {

    fileprivate static func inOrder(
        _ tree: borrowing Tree<Int>.Binary
    ) -> [Int] {
        var result: [Int] = []
        tree.forEach.inOrder { result.append($0) }
        return result
    }

    fileprivate static func preOrder(
        _ tree: borrowing Tree<Int>.Binary
    ) -> [Int] {
        var result: [Int] = []
        tree.forEach.preOrder { result.append($0) }
        return result
    }
}

extension `Tree.Binary.Builder`.`Level Order` {

    @Test
    func `Single element makes root`() {
        let tree = Tree<Int>.Binary { 1 }
        #expect(tree.count == 1)
    }

    @Test
    func `Three elements form root with two children`() {
        let tree = Tree<Int>.Binary {
            1
            2
            3
        }

        #expect(`Tree.Binary.Builder`.inOrder(tree) == [2, 1, 3])

        #expect(`Tree.Binary.Builder`.preOrder(tree) == [1, 2, 3])
    }

    @Test
    func `Seven elements form complete tree`() {

        let tree = Tree<Int>.Binary {
            1
            2
            3
            4
            5
            6
            7
        }

        #expect(`Tree.Binary.Builder`.inOrder(tree) == [4, 2, 5, 1, 6, 3, 7])

        #expect(`Tree.Binary.Builder`.preOrder(tree) == [1, 2, 4, 5, 3, 6, 7])
    }
}

extension `Tree.Binary.Builder`.Unit {

    @Test
    func `Empty block produces empty tree`() {
        let tree = Tree<Int>.Binary {}
        #expect(tree.isEmpty)
    }

    @Test
    func `Optional element - some`() {
        let value: Int? = 42
        let tree = Tree<Int>.Binary { value }
        #expect(tree.count == 1)
    }

    @Test
    func `Optional element - none produces empty tree`() {
        let value: Int? = nil
        let tree = Tree<Int>.Binary { value }
        #expect(tree.isEmpty)
    }

    @Test
    func `Two elements - root with left child only`() {
        let tree = Tree<Int>.Binary {
            10
            20
        }
        #expect(tree.count == 2)

        #expect(`Tree.Binary.Builder`.preOrder(tree) == [10, 20])
    }
}

extension `Tree.Binary.Builder`.Unit {

    @Test
    func `Conditional include adds to layout`() {
        let include = true
        let tree = Tree<Int>.Binary {
            1
            2
            if include {
                3
            }
        }
        #expect(tree.count == 3)
    }

    @Test
    func `Conditional exclude reduces layout`() {
        let include = false
        let tree = Tree<Int>.Binary {
            1
            2
            if include {
                3
            }
        }
        #expect(tree.count == 2)
    }

    @Test
    func `For loop builds wide tree`() {
        let tree = Tree<Int>.Binary {
            for i in 1...7 {
                i
            }
        }
        #expect(tree.count == 7)
    }
}

extension `Tree.Binary.Builder`.`Edge Case` {

    @Test
    func `Many elements`() {
        let tree = Tree<Int>.Binary {
            for i in 0..<31 {
                i
            }
        }
        #expect(tree.count == 31)
    }

    @Test
    func `Mixed with Optional none entries`() {
        let none: Int? = nil
        let some: Int? = 99
        let tree = Tree<Int>.Binary {
            1
            none
            some
        }

        #expect(tree.count == 2)
    }
}

extension `Tree.Binary.Builder`.Integration {

    @Test
    func `Builder result accepts further inserts via imperative API`() throws {
        var tree = Tree<Int>.Binary {
            1
            2
            3
        }

        let root = tree.root!
        let leftOfRoot = tree.child.at(.left, of: root)!
        try tree.insert(99, at: .left(of: leftOfRoot))
        #expect(tree.count == 4)
    }
}

extension `Tree.Binary.Builder`.`Static Methods` {

    @Test
    func `buildExpression single element`() {
        let result = Tree<Int>.N<2>.Builder.buildExpression(42)
        #expect(result == [42])
    }

    @Test
    func `buildExpression array`() {
        let result = Tree<Int>.N<2>.Builder.buildExpression([1, 2, 3])
        #expect(result == [1, 2, 3])
    }

    @Test
    func `buildPartialBlock accumulated`() {
        let result = Tree<Int>.N<2>.Builder.buildPartialBlock(
            accumulated: [1, 2],
            next: [3, 4]
        )
        #expect(result == [1, 2, 3, 4])
    }

    @Test
    func `buildArray flattens components`() {
        let result = Tree<Int>.N<2>.Builder.buildArray([[1, 2], [3]])
        #expect(result == [1, 2, 3])
    }
}
