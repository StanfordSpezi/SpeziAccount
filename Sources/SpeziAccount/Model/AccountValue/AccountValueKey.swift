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


// TODO rename everything to AccountDetail, AccountDetailCategory?

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
    /// The ``DataDisplayView`` that is used to display a value for this account value.
    ///
    /// This view is used in views like the ``AccountOverview`` to display the current value for this `AccountValueKey`.
    /// - Note: This View implementation is automatically provided if the `Value` is a String or the `Value`
    ///     conforms to `CustomLocalizedStringResourceConvertible`.
    associatedtype DataDisplay: DataDisplayView<Self>

    /// The ``DataEntryView`` that is used to enter a value for this account value.
    ///
    /// This view is wrapped into a ``GeneralizedDataEntryView`` and used in views like the ``SignupForm`` to enter the account value.
    /// For example, for a String-based account value, one might define a ``DataEntryView`` based on `TextField` or ``VerifiableTextField``.
    associatedtype DataEntry: DataEntryView<Self>

    /// The localized name describing a value of this `AccountValueKey`.
    static var name: LocalizedStringResource { get }


    /// The category of the account value.
    ///
    /// The ``AccountValueCategory`` is used to group ``DataEntryView``s in views like the ``SignupForm``.
    /// Use ``AccountValueCategory/other`` to move the ``DataEntry`` view to a unnamed group at the bottom.
    static var category: AccountValueCategory { get }

    /// An empty value instance of the account value
    ///
    /// An empty value (e.g., a empty String) is required when the user is asked to supply a new value for the AccountValue
    /// in views like the ``SignupForm``.
    ///
    /// - Note: For this property there are default implementations for some standard types or for types that conform to the
    ///     `DefaultInitializable` protocol of the `Spezi` framework.
    static var emptyValue: Value { get }

    /// A unique identifier for an account value.
    ///
    /// - Note: A default implementation is provided.
    static var id: ObjectIdentifier { get }
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

    public static func isContained<Storage: AccountValueStorageContainer>(in container: Storage) -> Bool {
        container.contains(Self.self)
    }
}

extension AccountValueKey where Value: DefaultInitializable {
    public static var emptyValue: Value {
        .init()
    }
}

extension AccountValueKey where Value: StringProtocol {
    public static var emptyValue: Value {
        ""
    }
}

extension AccountValueKey where Value == Date {
    public static var emptyValue: Value {
        Date()
    }
}

extension AccountValueKey where Value: AdditiveArithmetic {
    public static var emptyValue: Value {
        // this catches all the numeric types
        .zero
    }
}

extension AccountValueKey where Value: ExpressibleByArrayLiteral {
    public static var emptyValue: Value {
        []
    }
}

extension AccountValueKey where Value: ExpressibleByDictionaryLiteral {
    public static var emptyValue: Value {
        [:]
    }
}
