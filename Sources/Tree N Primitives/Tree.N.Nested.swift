public import Tree_Primitives

public enum __TreeNNested<Element> {}

extension __Tree where S: __TreeNStorage, S.Address == __TreeNChildSlot<2>, S.Element: Copyable {

    public typealias Nested = __TreeNNested<S.Element>
}
