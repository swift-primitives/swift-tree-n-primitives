public import Tree_Primitives

extension __Tree where S: ~Copyable, S: __TreeStorage {

    public typealias N<let n: Int> = __Tree<TreeStorage.N<S.Element, n>>

    public typealias Binary = __Tree<TreeStorage.N<S.Element, 2>>
}
