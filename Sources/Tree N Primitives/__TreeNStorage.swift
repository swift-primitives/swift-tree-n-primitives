public import Tree_Primitives

public protocol __TreeNStorage: __TreeStorage, ~Copyable where Error == __TreeError {

    static var _arity: Int { get }
}
