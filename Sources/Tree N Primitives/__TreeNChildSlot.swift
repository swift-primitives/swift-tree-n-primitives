public struct __TreeNChildSlot<let n: Int>: Sendable, Equatable, Hashable {

    public let index: Int

    @inlinable
    public init?(_ index: Int) {
        guard index >= 0 && index < n else { return nil }
        self.index = index
    }

    @usableFromInline
    init(__unchecked index: Int) {
        self.index = index
    }
}

extension __TreeNChildSlot where n == 2 {

    @inlinable
    public static var left: Self { Self(__unchecked: 0) }

    @inlinable
    public static var right: Self { Self(__unchecked: 1) }
}

extension __TreeNChildSlot where n == 3 {

    @inlinable
    public static var left: Self { Self(__unchecked: 0) }

    @inlinable
    public static var middle: Self { Self(__unchecked: 1) }

    @inlinable
    public static var right: Self { Self(__unchecked: 2) }
}

extension __TreeNChildSlot where n == 4 {

    @inlinable
    public static var northwest: Self { Self(__unchecked: 0) }

    @inlinable
    public static var northeast: Self { Self(__unchecked: 1) }

    @inlinable
    public static var southwest: Self { Self(__unchecked: 2) }

    @inlinable
    public static var southeast: Self { Self(__unchecked: 3) }
}

extension __TreeNChildSlot: CustomStringConvertible {

    public var description: String {
        "ChildSlot(\(index))"
    }
}
