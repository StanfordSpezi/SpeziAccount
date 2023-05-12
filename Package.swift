// swift-tools-version:5.7

//
// This source file is part of the Spezi open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziAccount",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "SpeziAccount", targets: ["SpeziAccount"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", .upToNextMinor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "SpeziAccount",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziViews", package: "SpeziViews")
            ]
        ),
        .testTarget(
            name: "SpeziAccountTests",
            dependencies: [
                .target(name: "SpeziAccount")
            ]
        )
    ]
)
