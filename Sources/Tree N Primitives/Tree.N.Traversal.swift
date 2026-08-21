public import Tree_Primitives

extension __Tree where S: __TreeNStorage, S.Element: Copyable {

    public var preOrder: __TreeNOrder.Pre.Sequence<S> {
        __TreeNOrder.Pre.Sequence<S>(tree: self)
    }

    public var postOrder: __TreeNOrder.Post.Sequence<S> {
        __TreeNOrder.Post.Sequence<S>(tree: self)
    }

    public var levelOrder: __TreeNOrder.Level.Sequence<S> {
        __TreeNOrder.Level.Sequence<S>(tree: self)
    }
}

extension __Tree where S: __TreeNStorage, S.Element: Copyable, S.Address == __TreeNChildSlot<2> {

    public var inOrder: __TreeNOrder.In.Sequence<S> {
        __TreeNOrder.In.Sequence<S>(tree: self)
    }
}
