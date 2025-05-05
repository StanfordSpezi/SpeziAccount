//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Provide categories ui components of an `AccountKey`.
///
/// A `AccountKeyCategory` is used in views like ``SignupForm`` to visually separate ``AccountKey``
/// and group similar elements into sections.
///
/// ## Topics
///
/// ### Default Categories
/// - ``credentials``
/// - ``name``
/// - ``contactDetails``
/// - ``personalDetails``
/// - ``other``
public struct AccountKeyCategory {
    /// A category to group account credentials.
    public static let credentials = AccountKeyCategory(title: LocalizedStringResource("UP_CREDENTIALS", bundle: .atURL(from: .module)))

    /// A category to group account values capturing the user's name.
    public static let name = AccountKeyCategory(title: LocalizedStringResource("UP_NAME", bundle: .atURL(from: .module)))

    /// A category to group account values that capture the user's contact details.
    public static let contactDetails = AccountKeyCategory(title: LocalizedStringResource("UP_CONTACT_DETAILS", bundle: .atURL(from: .module)))

    /// A category to group account values that capture other personal details.
    public static let personalDetails = AccountKeyCategory(title: LocalizedStringResource("UP_PERSONAL_DETAILS", bundle: .atURL(from: .module)))

    /// A default, unnamed category for any account values
    public static let other = AccountKeyCategory()


    /// The localized section title.
    public let categoryTitle: LocalizedStringResource?

    // the only category allowed without a title is the `other` category
    private init(title categoryTitle: LocalizedStringResource? = nil) {
        self.categoryTitle = categoryTitle
    }

    /// Instantiate a new `AccountKeyCategory`.
    /// - Parameter categoryTitle: The localized section title. The key is also used a identifier for the `Identifiable` conformance.
    public init(title categoryTitle: LocalizedStringResource) {
        self.categoryTitle = categoryTitle
    }
}


extension AccountKeyCategory: Sendable {}


extension AccountKeyCategory: Identifiable, Hashable {
    /// A string based identifier relying on the key of the ``categoryTitle``.
    ///
    /// The magic constant `#none#` is used for the ``other`` category.
    public var id: String {
        categoryTitle?.key ?? "#none#" // magic constant for the "other" category
    }

    /// Default `Equatable` implementation.
    public static func == (lhs: AccountKeyCategory, rhs: AccountKeyCategory) -> Bool {
        lhs.id == rhs.id
    }

    /// Default `Hashable` implementation.
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
