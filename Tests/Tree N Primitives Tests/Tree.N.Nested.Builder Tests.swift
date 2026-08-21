import Testing
import Tree_N_Primitives_Test_Support

@testable import Tree_N_Primitives

@Suite
struct `Tree.N<2>.Nested.Builder` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Sparse {}
    @Suite struct `Depth Coverage` {}
    @Suite struct `Static Methods` {}
}

private typealias BNode = Tree<Int>.N<2>.Nested.Node

extension `Tree.N<2>.Nested.Builder` {
    fileprivate static func preOrder(_ tree: borrowing Tree<Int>.N<2>) -> [Int] {
        var result: [Int] = []
        tree.forEach.preOrder { result.append($0) }
        return result
    }

    fileprivate static func inOrder(_ tree: borrowing Tree<Int>.N<2>) -> [Int] {
        var result: [Int] = []
        tree.forEach.inOrder { result.append($0) }
        return result
    }
}

extension `Tree.N<2>.Nested.Builder`.Unit {

    @Test
    func `Single leaf node`() {
        let tree = Tree<Int>.N<2> {
            BNode(42)
        }
        #expect(tree.count == 1)
        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [42])
    }

    @Test
    func `Root with both children`() {
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2)
                BNode(3)
            }
        }

        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2, 3])

        #expect(`Tree.N<2>.Nested.Builder`.inOrder(tree) == [2, 1, 3])
    }

    @Test
    func `Three-level complete tree`() {
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2) {
                    BNode(4)
                    BNode(5)
                }
                BNode(3) {
                    BNode(6)
                    BNode(7)
                }
            }
        }

        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2, 4, 5, 3, 6, 7])

        #expect(`Tree.N<2>.Nested.Builder`.inOrder(tree) == [4, 2, 5, 1, 6, 3, 7])
    }
}

extension `Tree.N<2>.Nested.Builder`.Sparse {

    @Test
    func `Root with left child only`() {
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2)
            }
        }

        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2])
    }

    @Test
    func `Asymmetric tree - left subtree deeper than right`() {
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2) {
                    BNode(4) {
                        BNode(8)
                    }
                }
                BNode(3)
            }
        }

        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2, 4, 8, 3])
    }

    @Test
    func `Left-skewed tree (linked-list shape)`() {
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2) {
                    BNode(3) {
                        BNode(4)
                    }
                }
            }
        }
        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2, 3, 4])
    }
}

extension `Tree.N<2>.Nested.Builder`.`Edge Case` {

    @Test
    func `Conditional child include`() {
        let include = true
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2)
                if include {
                    BNode(3)
                }
            }
        }
        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2, 3])
    }

    @Test
    func `Conditional child exclude`() {
        let include = false
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2)
                if include {
                    BNode(3)
                }
            }
        }

        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2])
    }

    @Test
    func `If-else child branch`() {
        let condition = true
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                if condition {
                    BNode(10)
                } else {
                    BNode(20)
                }
            }
        }
        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 10])
    }
}

extension `Tree.N<2>.Nested.Builder`.`Depth Coverage` {

    @Test
    func `Depth 4 tree`() {
        let tree = Tree<Int>.N<2> {
            BNode(1) {
                BNode(2) {
                    BNode(3) {
                        BNode(4) {
                            BNode(5)
                        }
                    }
                }
            }
        }
        #expect(tree.count == 5)
        #expect(`Tree.N<2>.Nested.Builder`.preOrder(tree) == [1, 2, 3, 4, 5])
    }

    @Test
    func `Balanced depth-3 with 7 nodes`() {
        let tree = Tree<Int>.N<2> {
            BNode(4) {
                BNode(2) {
                    BNode(1)
                    BNode(3)
                }
                BNode(6) {
                    BNode(5)
                    BNode(7)
                }
            }
        }

        #expect(`Tree.N<2>.Nested.Builder`.inOrder(tree) == [1, 2, 3, 4, 5, 6, 7])
    }
}

extension `Tree.N<2>.Nested.Builder`.`Static Methods` {

    @Test
    func `buildExpression single Node`() {
        let result = Tree<Int>.N<2>.Nested.Builder.buildExpression(BNode(42))
        #expect(result.count == 1)
        #expect(result[0].element == 42)
    }

    @Test
    func `buildBlock empty`() {
        let result = Tree<Int>.N<2>.Nested.Builder.buildBlock()
        #expect(result.isEmpty)
    }

    @Test
    func `buildPartialBlock accumulated and next`() {
        let acc: [BNode] = [BNode(1)]
        let next: [BNode] = [BNode(2)]
        let result = Tree<Int>.N<2>.Nested.Builder.buildPartialBlock(
            accumulated: acc,
            next: next
        )
        #expect(result.count == 2)
        #expect(result[0].element == 1)
        #expect(result[1].element == 2)
    }

    @Test
    func `buildArray flattens components`() {
        let result = Tree<Int>.N<2>.Nested.Builder.buildArray([
            [BNode(1)],
            [BNode(2), BNode(3)],
        ])
        #expect(result.count == 3)
    }
}
