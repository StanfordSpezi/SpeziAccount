// swift-tools-version:5.9

//
// This source file is part of the Spezi open source project
// 
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
import PackageDescription


#if swift(<6)
let swiftConcurrency: SwiftSetting = .enableExperimentalFeature("StrictConcurrency")
#else
let swiftConcurrency: SwiftSetting = .enableUpcomingFeature("StrictConcurrency")
#endif


let package = Package(
    name: "SpeziAccount",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "SpeziAccount", targets: ["SpeziAccount"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "1.1.3"),
        .package(url: "https://github.com/StanfordSpezi/Spezi", from: "1.6.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", from: "1.5.0"),
        .package(url: "https://github.com/StanfordBDHG/XCTRuntimeAssertions", from: "1.1.1"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0")
    ] + swiftLintPackage(),
    targets: [
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
                .product(name: "Atomics", package: "swift-atomics")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                swiftConcurrency
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziAccountTests",
            dependencies: [
                .target(name: "SpeziAccount"),
                .product(name: "XCTRuntimeAssertions", package: "XCTRuntimeAssertions")
            ],
            swiftSettings: [
                swiftConcurrency
            ],
            plugins: [] + swiftLintPlugin()
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", .upToNextMinor(from: "0.55.1"))]
    } else {
        []
    }
}
