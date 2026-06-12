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
        // MARK: - Ops modules (isolated Copyable conformances); `Tree N Primitives` doubles as the [MOD-005] umbrella
        .library(name: "Tree N Primitives", targets: ["Tree N Primitives"]),
        // MARK: - Test Support
        .library(name: "Tree N Primitives Test Support", targets: ["Tree N Primitives Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-tree-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-column-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-shared-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-storage-arena-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-store-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-ring-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-queue-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-stack-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-array-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Type modules
        // Base bounded-arity Tree.N + Tree.Binary (= Tree.N<2>): type + storage
        // (@usableFromInline internal) + all @inlinable ops + Order iterators +
        // Order.*.Sequence structs (conformances isolated in the ops module) +
        // Copyable/Sendable markers (co-located per [MEM-COPY-006]). Backed by the
        // generational column (`Column.Generational<Node>` behind the `Shared` CoW box).
        .target(
            name: "Tree N Primitive",
            dependencies: [
                .product(name: "Tree Primitives Core", package: "swift-tree-primitives"),
                .product(name: "Column Primitives", package: "swift-column-primitives"),
                .product(name: "Shared Primitive", package: "swift-shared-primitives"),
                .product(name: "Storage Generational Primitives", package: "swift-storage-arena-primitives"),
                .product(name: "Store Primitive", package: "swift-store-primitives"),
                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Queue Primitives", package: "swift-queue-primitives"),
                .product(name: "Stack Primitives", package: "swift-stack-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
            ]
        ),
        // MARK: - Umbrella: base Swift.Sequence conformances + re-export of the base type.
        .target(
            name: "Tree N Primitives",
            dependencies: [
                "Tree N Primitive",
            ]
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
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
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
