public import Tree_Primitives

extension __TreeInsertPosition where Address == __TreeNChildSlot<2> {

    @inlinable
    public static func left(of position: __TreePosition) -> Self {
        .child(of: position, at: .left)
    }

    @inlinable
    public static func right(of position: __TreePosition) -> Self {
        .child(of: position, at: .right)
    }
}

extension __TreeInsertPosition where Address == __TreeNChildSlot<3> {

    @inlinable
    public static func left(of position: __TreePosition) -> Self {
        .child(of: position, at: .left)
    }

    @inlinable
    public static func middle(of position: __TreePosition) -> Self {
        .child(of: position, at: .middle)
    }

    @inlinable
    public static func right(of position: __TreePosition) -> Self {
        .child(of: position, at: .right)
    }
}

extension __TreeInsertPosition where Address == __TreeNChildSlot<4> {

    @inlinable
    public static func northwest(of position: __TreePosition) -> Self {
        .child(of: position, at: .northwest)
    }

    @inlinable
    public static func northeast(of position: __TreePosition) -> Self {
        .child(of: position, at: .northeast)
    }

    @inlinable
    public static func southwest(of position: __TreePosition) -> Self {
        .child(of: position, at: .southwest)
    }

    @inlinable
    public static func southeast(of position: __TreePosition) -> Self {
        .child(of: position, at: .southeast)
    }
}
