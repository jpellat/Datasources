// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Datasources",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v7)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Datasources",
            targets: ["Datasources"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Datasources",
            dependencies: []),
        .testTarget(
            name: "DatasourcesTests",
            dependencies: ["Datasources"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
