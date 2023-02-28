// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "swift-referencing",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Referencing",
            targets: ["Referencing"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/minacle/swift-locks",
            .upToNextMajor(from: "2.1.1")),
    ],
    targets: [
        .target(
            name: "Referencing",
            dependencies: [
                .product(
                    name: "Locks",
                    package: "swift-locks"),
            ]),
        .testTarget(
            name: "ReferencingTests",
            dependencies: [
                .target(name: "Referencing"),
            ]),
    ]
)
