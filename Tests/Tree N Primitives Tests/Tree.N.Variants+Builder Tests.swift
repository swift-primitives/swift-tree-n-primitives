// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing
import Tree_N_Primitives_Test_Support

@testable import Tree_N_Primitives

@Suite("Tree.N variants + Builder")
struct TreeNVariantsBuilderTests {
    @Suite struct BoundedTree {}
}

extension TreeNVariantsBuilderTests.BoundedTree {
    @Test
    func `Bounded within capacity`() throws {
        let tree = try Tree<Int>.N<2>.Bounded(capacity: 8) { 1; 2; 3 }
        let isEmpty = tree.isEmpty
        #expect(!isEmpty)
    }
}
