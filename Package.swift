// swift-tools-version:5.9

//
// This source file is part of the Spezi open source project
// 
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import CompilerPluginSupport
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
        .iOS(.v17),
        .macOS(.v14), // we need to specify that to run macro tests as they only run on the host platform
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SpeziAccount", targets: ["SpeziAccount"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation", from: "2.0.0-beta.2"),
        .package(url: "https://github.com/StanfordSpezi/Spezi", from: "1.7.3"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", from: "1.6.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziStorage", from: "1.2.0"),
        .package(url: "https://github.com/StanfordBDHG/XCTRuntimeAssertions", from: "1.1.1"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-atomics", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0-prerelease-2024-08-14"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0")
    ] + swiftLintPackage(),
    targets: [
        .macro(
            name: "SpeziAccountMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax")
            ],
            swiftSettings: [
                swiftConcurrency
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziAccount",
            dependencies: [
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziViews", package: "SpeziViews"),
                .product(name: "SpeziPersonalInfo", package: "SpeziViews"),
                .product(name: "SpeziValidation", package: "SpeziViews"),
                .product(name: "SpeziLocalStorage", package: "SpeziStorage"),
                .product(name: "SpeziSecureStorage", package: "SpeziStorage"),
                .product(name: "XCTRuntimeAssertions", package: "XCTRuntimeAssertions"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "Atomics", package: "swift-atomics"),
                .target(name: "SpeziAccountMacros")
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
                .product(name: "XCTRuntimeAssertions", package: "XCTRuntimeAssertions"),
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "XCTSpezi", package: "Spezi"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            swiftSettings: [
                swiftConcurrency
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziAccountMacrosTests",
            dependencies: [
                "SpeziAccountMacros",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
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
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
