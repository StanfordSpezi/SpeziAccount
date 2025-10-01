// swift-tools-version:6.2

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


let package = Package(
    name: "SpeziAccount",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14), // we need to specify that to run macro tests as they only run on the host platform
        .macCatalyst(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SpeziAccount", targets: ["SpeziAccount"]),
        .library(name: "XCTSpeziAccount", targets: ["XCTSpeziAccount"]),
        .library(name: "SpeziAccountPhoneNumbers", targets: ["SpeziAccountPhoneNumbers"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.2.1"),
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.8.2"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", from: "1.12.4"),
        .package(url: "https://github.com/StanfordSpezi/SpeziStorage.git", from: "2.1.1"),
        .package(url: "https://github.com/StanfordBDHG/XCTRuntimeAssertions.git", from: "2.0.0"),
        .package(url: "https://github.com/StanfordBDHG/XCTestExtensions.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.1.0")
    ] + swiftLintPackage(),
    targets: [
        .macro(
            name: "SpeziAccountMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
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
                .product(name: "RuntimeAssertions", package: "XCTRuntimeAssertions"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "Atomics", package: "swift-atomics"),
                .target(name: "SpeziAccountMacros")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "XCTSpeziAccount",
            dependencies: [
                .target(name: "SpeziAccount"),
                .product(name: "XCTestExtensions", package: "XCTestExtensions")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziAccountPhoneNumbers",
            dependencies: [
                .target(name: "SpeziAccount"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziAccountTests",
            dependencies: [
                .target(name: "SpeziAccount"),
                .target(name: "SpeziAccountPhoneNumbers"),
                .product(name: "XCTRuntimeAssertions", package: "XCTRuntimeAssertions"),
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziTesting", package: "Spezi"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            resources: [
                .process("__Snapshots__")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziAccountMacrosTests",
            dependencies: [
                "SpeziAccountMacros",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
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
        [.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.61.0")]
    } else {
        []
    }
}
