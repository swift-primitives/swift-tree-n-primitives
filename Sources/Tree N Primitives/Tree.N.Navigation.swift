public import Tree_Primitives

extension __Tree where S: __TreeNStorage & ~Copyable, S.Address == __TreeNChildSlot<2> {

    @inlinable
    public func left(of position: Position) -> Position? {
        _child(of: position, at: .left)
    }

    @inlinable
    public func right(of position: Position) -> Position? {
        _child(of: position, at: .right)
    }
}
