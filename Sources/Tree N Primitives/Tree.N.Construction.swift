public import Index_Primitives
public import Tree_Primitives

extension __Tree where S: ~Copyable {

    @inlinable
    public init<Element: ~Copyable, let n: Int>() where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>())
    }

    @inlinable
    public init<Element: ~Copyable, let n: Int>(
        minimumCapacity: Index_Primitives.Index<Element>.Count
    ) where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>(minimumCapacity: minimumCapacity))
    }

    @inlinable
    public init<Element, let n: Int>() where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>())
    }

    @inlinable
    public init<Element, let n: Int>(
        minimumCapacity: Index_Primitives.Index<Element>.Count
    ) where S == TreeStorage.N<Element, n> {
        self.init(storage: TreeStorage.N<Element, n>(minimumCapacity: minimumCapacity))
    }
}
