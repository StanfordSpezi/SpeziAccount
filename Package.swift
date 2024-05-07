// swift-tools-version:5.9

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
        .iOS(.v17)
    ],
    products: [
        .library(name: "SpeziAccount", targets: ["SpeziAccount"]),
        .library(name: "AccountValues", targets: ["AccountValues"]),
        .library(name: "AccountService", targets: ["AccountService"]) // TODO: remove them again
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "1.0.0"),
        .package(url: "https://github.com/StanfordSpezi/Spezi", from: "1.2.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", from: "1.3.0"),
        .package(url: "https://github.com/StanfordBDHG/XCTRuntimeAssertions", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4")
    ],
    targets: [
        .target(
            name: "AccountValues",
            dependencies: [
                .product(name: "SpeziFoundation", package: "SpeziFoundation")
            ]
        ),
        .target(
            name: "AccountService",
            dependencies: [
                .target(name: "AccountValues")
            ]
        ),
        .target(
            name: "SpeziAccount",
            dependencies: [
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziViews", package: "SpeziViews"),
                .product(name: "SpeziPersonalInfo", package: "SpeziViews"),
                .product(name: "SpeziValidation", package: "SpeziViews"),
                .product(name: "XCTRuntimeAssertions", package: "XCTRuntimeAssertions"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .target(name: "AccountValues"),
                .target(name: "AccountService")
            ],
            resources: [
                .process("Resources")
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
