public import Tree_Primitives

@resultBuilder
public enum __TreeNBuilder<Element> {

    @inlinable
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }

    @inlinable
    public static func buildExpression(_ expression: [Element]) -> [Element] {
        expression
    }

    @inlinable
    public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> [Element]
    where S.Element == Element {
        Array(expression)
    }

    @inlinable
    public static func buildExpression(_ expression: Element?) -> [Element] {
        expression.map { [$0] } ?? []
    }

    @inlinable
    public static func buildPartialBlock(first: [Element]) -> [Element] {
        first
    }

    @inlinable
    public static func buildPartialBlock(first: Void) -> [Element] {
        []
    }

    @inlinable
    public static func buildPartialBlock(first: Never) -> [Element] {}

    @inlinable
    public static func buildPartialBlock(
        accumulated: consuming [Element],
        next: [Element]
    ) -> [Element] {
        accumulated.append(contentsOf: next)
        return accumulated
    }

    @inlinable
    public static func buildBlock() -> [Element] {
        []
    }

    @inlinable
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }

    @inlinable
    public static func buildEither(first: [Element]) -> [Element] {
        first
    }

    @inlinable
    public static func buildEither(second: [Element]) -> [Element] {
        second
    }

    @inlinable
    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.flatMap { $0 }
    }

    @inlinable
    public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
        component
    }
}

extension __Tree where S: __TreeNStorage, S.Address == __TreeNChildSlot<2>, S.Element: Copyable {

    public typealias Builder = __TreeNBuilder<S.Element>
}

extension __Tree where S: ~Copyable {

    @inlinable
    public init<Element>(
        @__TreeNBuilder<Element> _ builder: () -> [Element]
    ) where S == TreeStorage.N<Element, 2> {
        self.init()
        let elements = builder()
        guard !elements.isEmpty else { return }

        var positions: [__TreePosition] = []

        try! positions.append(self.insert(elements[0], at: .root))

        var i = 1
        var parentIndex = 0
        while i < elements.count {
            let parent = positions[parentIndex]

            if i < elements.count {

                try! positions.append(self.insert(elements[i], at: .left(of: parent)))
                i += 1
            }

            if i < elements.count {

                try! positions.append(self.insert(elements[i], at: .right(of: parent)))
                i += 1
            }
            parentIndex += 1
        }
    }
}
