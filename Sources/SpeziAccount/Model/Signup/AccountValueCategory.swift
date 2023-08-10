//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


public struct AccountValueCategory {
    public static let credentials = AccountValueCategory(
        id: "credentials",
        title: LocalizedStringResource("UP_CREDENTIALS", bundle: .atURL(from: .module))
    )

    public static let name = AccountValueCategory(id: "name", title: LocalizedStringResource("UP_NAME", bundle: .atURL(from: .module)))

    public static let contactDetails = AccountValueCategory(
        id: "contactDetails",
        title: LocalizedStringResource("UP_CONTACT_DETAILS", bundle: .atURL(from: .module))
    )

    public static let personalDetails = AccountValueCategory(
        id: "personalDetails",
        title: LocalizedStringResource("UP_PERSONAL_DETAILS", bundle: .atURL(from: .module))
    )

    public static let other = AccountValueCategory(id: "other")

    public let id: String
    public let categoryTitle: LocalizedStringResource?

    public init(id: String, title categoryTitle: LocalizedStringResource? = nil) {
        self.id = id
        self.categoryTitle = categoryTitle
    }

    public init(title categoryTitle: LocalizedStringResource? = nil) {
        self.id = UUID().uuidString // TODO document how predictable titles are nice for extensability!
        self.categoryTitle = categoryTitle
    }
}


extension AccountValueCategory: Identifiable, Hashable {
    public static func == (lhs: AccountValueCategory, rhs: AccountValueCategory) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
