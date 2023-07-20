// swift-tools-version:5.7

//
// This source file is part of the Spezi open source project
// 
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
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
        .package(url: "https://github.com/StanfordSpezi/Spezi", .upToNextMinor(from: "0.6.0")),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/StanfordBDHG/XCTRuntimeAssertions", .upToNextMinor(from: "0.2.5"))
    ],
    targets: [
        .target(
            name: "SpeziAccount",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziViews", package: "SpeziViews"),
                .product(name: "XCTRuntimeAssertions", package: "XCTRuntimeAssertions")
            ]
        ),
        .testTarget(
            name: "SpeziAccountTests",
            dependencies: [
                .target(name: "SpeziAccount"),
                .product(name: "XCTRuntimeAssertions", package: "XCTRuntimeAssertions")
            ]
        )
    ]
)
