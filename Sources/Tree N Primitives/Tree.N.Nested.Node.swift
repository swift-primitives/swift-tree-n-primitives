extension __TreeNNested {

    public struct Node {

        public let element: Element

        public let children: [Self]

        @inlinable
        public init(_ element: Element) {
            self.element = element
            self.children = []
        }

        @inlinable
        public init(
            _ element: Element,
            @__TreeNNested<Element>.Builder _ children: () -> [Self]
        ) {
            self.element = element
            self.children = children()
            precondition(
                self.children.count <= 2,
                "Tree.Binary.Nested.Node may declare at most 2 children (left, right)"
            )
        }
    }
}
