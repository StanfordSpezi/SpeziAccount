//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


public struct AccountServiceImage: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static var defaultValue: AccountServiceImage {
        AccountServiceImage(Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical))
    }

    public let image: Image

    public init(_ image: Image) {
        self.image = image
    }
}


extension AccountServiceConfiguration {
    public var image: Image {
        storage[AccountServiceImage.self].image
    }
}
