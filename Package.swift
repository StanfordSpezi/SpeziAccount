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
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SpeziAccount", targets: ["SpeziAccount"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/StanfordSpezi/Spezi", .upToNextMinor(from: "0.8.0")),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", .upToNextMinor(from: "0.6.1")),
        .package(url: "https://github.com/StanfordBDHG/XCTRuntimeAssertions", .upToNextMinor(from: "0.2.5")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.4")),


        // TODO: Shared
        .package(url: "https://github.com/apple/swift-openapi-generator", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "0.3.0")),

        // TODO: server
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/vapor/vapor", from: "4.84.0"),

        // TODO: client
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "0.3.0"))
    ],
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
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SpeziAccountWebService",
            dependencies: [
                .target(name: "SpeziAccount")
            ]
        ),
        .executableTarget(
            name: "ExampleWebService",
            dependencies: [
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIVapor",
                    package: "swift-openapi-vapor"
                ),
                .product(
                    name: "Vapor",
                    package: "vapor"
                )
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                )
            ]
        ),
        .executableTarget(
            name: "ExampleWebClient",
            dependencies: [
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession"
                ),
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                )
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
