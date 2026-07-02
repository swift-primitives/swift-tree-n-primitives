# Tree N Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-primitives/swift-tree-n-primitives/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-primitives/swift-tree-n-primitives/actions/workflows/ci.yml)

A bounded-arity n-ary tree — `Tree<Element>.N<n>` fixes the maximum child count at the type level, so a binary tree, a ternary tree, and a quadtree are the same type at different `n`, each with typed child slots (`.left`/`.right` at `n == 2`, `.northwest`…`.southeast` at `n == 4`) instead of raw child indices.

Nodes live in a generational arena rather than as allocated objects, so positions stay valid as the tree grows, stale positions are detected rather than dereferenced, and both the tree and its elements may be `~Copyable`. Traversals (pre-, in-, post-, and level-order) are iterative, not recursive — deep trees cannot overflow the stack.

---

## Key Features

- **Arity in the type** — `Tree<Element>.N<n>` bounds children per node at compile time; `Tree.Binary` is `Tree.N<2>`.
- **Typed child slots** — insertion targets are named positions (`.left(of:)`, `.right(of:)`, `.northwest(of:)`, …), and out-of-range slots are unrepresentable.
- **Sparse children** — child slots may be empty; inserting into an occupied slot throws a typed error instead of silently replacing.
- **Generational positions** — handles minted at insert keep resolving after growth; use-after-remove is caught by generation checks.
- **Iterative traversal** — `forEach.preOrder` / `.inOrder` / `.postOrder` / `.levelOrder` closures plus `preOrder` / `inOrder` / `postOrder` / `levelOrder` sequences, all stack-safe.
- **Move-only support** — both `Element` and the tree itself may be `~Copyable`; when `Element` is `Copyable`, copies are copy-on-write.
- **Result builders** — a flat level-order builder for complete trees and a nested DSL for sparse trees with explicit left/right placement.

---

## Quick Start

```swift
import Tree_N_Primitives

// A binary tree is Tree.N at n == 2 — child slots are typed, not indices.
var tree = Tree<Int>.N<2>()
let root = try tree.insert(1, at: .root)
let left = try tree.insert(2, at: .left(of: root))
_ = try tree.insert(3, at: .right(of: root))
_ = try tree.insert(4, at: .left(of: left))
_ = try tree.insert(5, at: .right(of: left))

// Iterative traversals — no recursion, deep-tree safe.
var visited: [Int] = []
tree.forEach.inOrder { visited.append($0) }    // [4, 2, 5, 1, 3]
tree.forEach.levelOrder { _ in }               // 1, 2, 3, 4, 5

// The same type at n == 4 is a quadtree with compass-named slots.
var quad = Tree<String>.N<4>()
let origin = try quad.insert("origin", at: .root)
_ = try quad.insert("upper-left", at: .northwest(of: origin))
_ = try quad.insert("lower-right", at: .southeast(of: origin))
```

Complete binary trees can be declared in level order with the flat builder; sparse trees take the nested DSL, where each node places its children explicitly:

```swift
import Tree_N_Primitives

// Level-order: 1 is the root, 2 and 3 its children.
let complete = Tree<Int>.Binary {
    1
    2
    3
}

// Nested DSL: left/right placement is explicit, holes are permitted.
typealias Node = Tree<Int>.Binary.Nested.Node
let sparse = Tree<Int>.Binary {
    Node(1) {
        Node(2) {
            Node(4)
            Node(5)
        }
        Node(3)
    }
}
```

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-tree-n-primitives.git", branch: "main")
]
```

Add a product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Tree N Primitives", package: "swift-tree-n-primitives")
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Tree N Primitives` | Umbrella — `Tree.N`, `Tree.Binary`, builders, traversal accessors, and the `Sequence`-style iteration conformances | Most consumers |
| `Tree N Primitive` | The `Tree.N` value type, typed slots, and traversal iterators, without the iteration conformances | Move-only use that must not pull in conformance machinery |
| `Tree N Primitives Test Support` | Shared fixtures for testing tree-consuming code | Test targets only |

---

## Error Handling

Mutations throw the typed `Tree.Error`, so exhaustive handling is checked by the compiler:

```
Tree.Error
├── .invalidPosition         // Position does not refer to a live node (stale or out of bounds)
├── .rootOccupied            // .root insert while the tree already has a root
├── .slotOccupied            // Target child slot already holds a node
├── .childIndexOutOfBounds   // Child index out of bounds (dynamic-arity trees)
└── .cannotRemoveNonLeaf     // remove(at:) on a non-leaf — use removeSubtree(at:)
```

```swift
do {
    _ = try tree.insert(6, at: .left(of: root))
} catch .rootOccupied {
    // .root insert on a non-empty tree
} catch .slotOccupied {
    // the target child slot already holds a node
} catch .invalidPosition {
    // the parent position no longer resolves (removed / invalidated)
} catch .childIndexOutOfBounds, .cannotRemoveNonLeaf {
    // raised by other operations (dynamic-arity addressing, non-leaf removal)
}
```

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |

---

## Related Packages

- swift-tree-primitives (not yet public) — the shared tree protocol, arena storage, and traversal algorithms this package's bounded-arity conformer builds on.
- [`swift-array-primitives`](https://github.com/swift-primitives/swift-array-primitives) — the growable column-generic array from the same family of arena-backed containers.
- [`swift-stack-primitives`](https://github.com/swift-primitives/swift-stack-primitives) — the stack discipline the iterative traversals use internally.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
