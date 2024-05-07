//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// A SwiftUI `Image` to visualize an ``AccountService``.
///
/// UI components may use this configuration to visually refer to an ``AccountService``.
///
/// Access the configuration via the ``AccountServiceConfiguration/image`` property.
public struct AccountServiceImage: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource, @unchecked Sendable {
    public static var defaultValue: AccountServiceImage {
        AccountServiceImage(Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical))
    }

    /// The SwiftUI `Image` of the ``AccountService``
    public let image: Image

    /// Initialize a new `AccountServiceImage`.
    /// - Parameter image: The SwiftUI `Image` of the ``AccountService``.
    public init(_ image: Image) {
        self.image = image
    }
}


extension AccountServiceConfiguration {
    /// Access the SwiftUI `Image` of an ``AccountService``.
    public var image: Image {
        storage[AccountServiceImage.self].image
    }
}
