public import Tree_Primitives

extension __TreeNNested {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(_ expression: Node) -> [Node] {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: [Node]) -> [Node] {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: Node?) -> [Node] {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildPartialBlock(first: [Node]) -> [Node] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Node] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Node] {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: [Node],
            next: [Node]
        ) -> [Node] {
            accumulated + next
        }

        @inlinable
        public static func buildBlock() -> [Node] {
            []
        }

        @inlinable
        public static func buildOptional(_ component: [Node]?) -> [Node] {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [Node]) -> [Node] {
            first
        }

        @inlinable
        public static func buildEither(second: [Node]) -> [Node] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[Node]]) -> [Node] {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Node]) -> [Node] {
            component
        }
    }
}

extension __Tree where S: ~Copyable {

    @inlinable
    @_disfavoredOverload
    public init<Element>(
        @__TreeNNested<Element>.Builder _ builder: () -> [__TreeNNested<Element>.Node]
    ) where S == TreeStorage.N<Element, 2> {
        let roots = builder()
        precondition(
            roots.count <= 1,
            "Tree.Binary.Nested builder must declare at most 1 root node"
        )
        self.init()
        guard let root = roots.first else { return }

        let rootPos = try! self.insert(root.element, at: .root)
        Self._insertChildren(root.children, parent: rootPos, into: &self)
    }

    @inlinable
    package static func _insertChildren<Element>(
        _ children: [__TreeNNested<Element>.Node],
        parent: __TreePosition,
        into tree: inout __Tree<TreeStorage.N<Element, 2>>
    ) where S == TreeStorage.N<Element, 2> {
        if children.count >= 1 {
            let leftNode = children[0]

            let leftPos = try! tree.insert(leftNode.element, at: .left(of: parent))
            _insertChildren(leftNode.children, parent: leftPos, into: &tree)
        }
        if children.count >= 2 {
            let rightNode = children[1]

            let rightPos = try! tree.insert(rightNode.element, at: .right(of: parent))
            _insertChildren(rightNode.children, parent: rightPos, into: &tree)
        }
    }
}
