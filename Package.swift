// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-tree-n-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Type modules (lean ~Copyable types + storage-touching @inlinable ops, co-located per [MOD-036])
        .library(name: "Tree N Primitive", targets: ["Tree N Primitive"]),
        .library(name: "Tree N Bounded Primitive", targets: ["Tree N Bounded Primitive"]),
        .library(name: "Tree N Inline Primitive", targets: ["Tree N Inline Primitive"]),
        .library(name: "Tree N Small Primitive", targets: ["Tree N Small Primitive"]),
        // MARK: - Ops modules (isolated Copyable conformances); `Tree N Primitives` doubles as the [MOD-005] umbrella
        .library(name: "Tree N Primitives", targets: ["Tree N Primitives"]),
        .library(name: "Tree N Bounded Primitives", targets: ["Tree N Bounded Primitives"]),
        .library(name: "Tree N Inline Primitives", targets: ["Tree N Inline Primitives"]),
        .library(name: "Tree N Small Primitives", targets: ["Tree N Small Primitives"]),
        // MARK: - Test Support
        .library(name: "Tree N Primitives Test Support", targets: ["Tree N Primitives Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-tree-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-arena-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-queue-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-stack-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-array-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Type modules
        // Base bounded-arity Tree.N + Tree.Binary (= Tree.N<2>): type + storage
        // (@usableFromInline internal) + all @inlinable ops + Order iterators +
        // Order.*.Sequence structs (conformances isolated in the ops module) +
        // Copyable/Sendable markers (co-located per [MEM-COPY-006]). Arena-backed.
        .target(
            name: "Tree N Primitive",
            dependencies: [
                .product(name: "Tree Primitives Core", package: "swift-tree-primitives"),
                .product(name: "Buffer Arena Primitives", package: "swift-buffer-arena-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Queue Primitives Core", package: "swift-queue-primitives"),
                .product(name: "Queue Dynamic Primitives", package: "swift-queue-primitives"),
                .product(name: "Stack Primitives", package: "swift-stack-primitives"),
            ]
        ),
        // Bounded capacity variant (fixed upfront allocation). Shares base Tree.N's
        // Node/ChildSlot/InsertPosition → depends on `Tree N Primitive`.
        .target(
            name: "Tree N Bounded Primitive",
            dependencies: [
                "Tree N Primitive",
                .product(name: "Buffer Arena Primitives", package: "swift-buffer-arena-primitives"),
                .product(name: "Queue Primitives Core", package: "swift-queue-primitives"),
                .product(name: "Queue Dynamic Primitives", package: "swift-queue-primitives"),
                .product(name: "Stack Primitives", package: "swift-stack-primitives"),
            ]
        ),
        // Inline capacity variant — unconditionally ~Copyable (@_rawLayout inline arena).
        // Distinct backing: Buffer Arena Inline ([MOD-008] — kept a separate target so
        // base/Bounded consumers do not pull the inline backing).
        .target(
            name: "Tree N Inline Primitive",
            dependencies: [
                "Tree N Primitive",
                .product(name: "Buffer Arena Inline Primitives", package: "swift-buffer-arena-primitives"),
                .product(name: "Buffer Arena Primitives", package: "swift-buffer-arena-primitives"),
                .product(name: "Queue Primitives Core", package: "swift-queue-primitives"),
                .product(name: "Queue Dynamic Primitives", package: "swift-queue-primitives"),
                .product(name: "Stack Primitives", package: "swift-stack-primitives"),
            ]
        ),
        // Small capacity variant — inline storage with heap spill.
        .target(
            name: "Tree N Small Primitive",
            dependencies: [
                "Tree N Primitive",
                .product(name: "Buffer Arena Inline Primitives", package: "swift-buffer-arena-primitives"),
                .product(name: "Buffer Arena Primitives", package: "swift-buffer-arena-primitives"),
                .product(name: "Queue Primitives Core", package: "swift-queue-primitives"),
                .product(name: "Queue Dynamic Primitives", package: "swift-queue-primitives"),
                .product(name: "Stack Primitives", package: "swift-stack-primitives"),
            ]
        ),

        // MARK: - Ops modules
        // Base ops + umbrella ([MOD-005]/[MOD-036] base-plural-as-umbrella): isolated
        // base Swift.Sequence conformances + re-export of base type and all variant ops.
        // Acyclic: depends on the variant OPS modules, which depend on TYPE modules — never back.
        .target(
            name: "Tree N Primitives",
            dependencies: [
                "Tree N Primitive",
                "Tree N Bounded Primitives",
                "Tree N Inline Primitives",
                "Tree N Small Primitives",
            ]
        ),
        .target(
            name: "Tree N Bounded Primitives",
            dependencies: ["Tree N Bounded Primitive"]
        ),
        .target(
            name: "Tree N Inline Primitives",
            dependencies: ["Tree N Inline Primitive"]
        ),
        .target(
            name: "Tree N Small Primitives",
            dependencies: ["Tree N Small Primitive"]
        ),

        // MARK: - Test Support ([MOD-024] spine)
        .target(
            name: "Tree N Primitives Test Support",
            dependencies: [
                "Tree N Primitives",
                .product(name: "Tree Primitives Test Support", package: "swift-tree-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Tree N Primitives Tests",
            dependencies: [
                "Tree N Primitives",
                "Tree N Primitives Test Support",
                .product(name: "Array Primitives", package: "swift-array-primitives"),
                .product(name: "Buffer Primitives", package: "swift-buffer-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
