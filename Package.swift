// swift-tools-version:5.7

//
// This source file is part of the CardinalKit open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "CardinalKitAccount",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "CardinalKitAccount", targets: ["CardinalKitAccount"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordBDHG/CardinalKit", .upToNextMinor(from: "0.3.3"))
    ],
    targets: [
        .target(
            name: "CardinalKitAccount",
            dependencies: [
                .product(name: "CardinalKit", package: "CardinalKit"),
                .product(name: "Views", package: "CardinalKit")
            ]
        ),
        .testTarget(
            name: "CardinalKitAccountTests",
            dependencies: [
                .target(name: "CardinalKitAccount")
            ]
        )
    ]
)
