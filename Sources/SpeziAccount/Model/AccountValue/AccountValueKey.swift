//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI
import XCTRuntimeAssertions


/// A typed storage key to store values associated with an user account.
///
/// The `AccountValueKey` protocol builds upon the [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository)
/// infrastructure provided by the `Spezi` framework.
///
/// The <doc:Adding-new-Account-Values> article provides a great overview on how to implement a custom account value.
///
/// - Important: The `Value` of an ``AccountValueKey`` must conform to `Sendable` such that storage containers
///     can be safely passed between actor boundaries.
///     `Equatable` conformance is required such that views like the ``SignupForm`` can react to changes
///     and validate input against a ``ValidationEngine``.
public protocol AccountValueKey: KnowledgeSource<AccountAnchor> where Value: Sendable, Value: Equatable {
    /// The ``DataEntryView`` for this specific `AccountValueKey` that is used to enter a value for this account value.
    ///
    /// This view is wrapped into a ``GeneralizedDataEntryView`` and used in views like the ``SignupForm`` to enter the account value.
    /// For example, for a String-based account value, one might define a ``DataEntryView`` based on `TextField` or ``VerifiableTextField``.
    associatedtype DataEntry: DataEntryView<Self>

    /// The category of the account value.
    ///
    /// The ``AccountValueCategory`` is used to group ``DataEntryView``s in views like the ``SignupForm``.
    /// Use ``AccountValueCategory/other`` to move the ``DataEntry`` view to a unnamed group at the bottom.
    static var category: AccountValueCategory { get }

    /// The ``DataEntryView`` wrapped into a ``GeneralizedDataEntryView`` used within data entry views like the ``SignupForm``.
    ///
    /// This property returns freshly instantiated ``GeneralizedDataEntryView`` with an empty `Value` (e.g., empty String).
    ///
    /// - Note: For this property there are default implementations for some standard types or for types that conform to the
    ///     `DefaultInitializable` protocol of the `Spezi` framework.
    static var dataEntryView: GeneralizedDataEntryView<DataEntry> { get } // we could provide a default value, but this way it's explicit!
}


extension AccountValueKey {
    /// A unique identifier for an account value.
    public static var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }

    /// The default identifier for the `@FocusState` property that is automatically handled by the ``GeneralizedDataEntryView``.
    public static var focusState: String {
        "\(Self.self)"
    }
}
