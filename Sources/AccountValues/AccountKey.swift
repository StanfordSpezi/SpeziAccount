//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI
import XCTRuntimeAssertions


/// A typed storage key to store values associated with an user account.
///
/// The `AccountKey` protocol builds upon the [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository)
/// infrastructure provided by the `Spezi` framework.
///
/// The <doc:Adding-new-Account-Values> article provides a great overview on how to implement a custom account value.
///
/// - Important: The `Value` of an ``AccountKey`` must conform to `Sendable` such that storage containers
///     can be safely passed between actor boundaries.
///     `Equatable` conformance is required such that views like the ``SignupForm`` can react to changes
///     and validate input.
///     `Codable` conformance is required such that ``AccountService``s of ``AccountStorageConstraint``s
///     can easily store arbitrarily defined account values.
///
/// ## Topics
///
/// ### Builtin Account Keys
/// - ``AccountIdKey``
/// - ``UserIdKey``
/// - ``PasswordKey``
/// - ``PersonNameKey``
/// - ``EmailAddressKey``
/// - ``DateOfBirthKey``
/// - ``GenderIdentityKey``
/// - ``ActiveAccountServiceKey``
public protocol AccountKey: KnowledgeSource<AccountAnchor> where Value: Sendable, Value: Equatable, Value: Codable {
    /// The ``DataDisplayView`` that is used to display a value for this account value.
    ///
    /// This view is used in views like the ``AccountOverview`` to display the current value for this `AccountKey`.
    /// - Note: This View implementation is automatically provided if the `Value` is a String or the `Value`
    ///     conforms to [CustomLocalizedStringResourceConvertible](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible).
    associatedtype DataDisplay: DataDisplayView<Self>

    /// The ``DataEntryView`` that is used to enter a value for this account value.
    ///
    /// This view is wrapped into a ``GeneralizedDataEntryView`` and used in views like the ``SignupForm`` to enter the account value.
    /// For example, for a String-based account value, one might define a ``DataEntryView`` based on `TextField`
    /// or [VerifiableTextField](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/spezivalidation/verifiabletextfield).
    associatedtype DataEntry: DataEntryView<Self>

    /// The localized name describing a value of this `AccountKey`.
    static var name: LocalizedStringResource { get }

    /// A string-based identifier that is meant to be stable. Used by storage modules.
    ///
    /// By default this maps to the type name.
    static var identifier: String { get }


    /// The category of the account key.
    ///
    /// The ``AccountKeyCategory`` is used to group ``DataEntryView``s in views like the ``SignupForm``.
    /// Use ``AccountKeyCategory/other`` to move the ``DataEntry`` view to a unnamed group at the bottom.
    static var category: AccountKeyCategory { get }

    /// The ``InitialValue`` that is used when supplying a new account value.
    ///
    /// An empty value (e.g., a empty String) is required when the user is asked to supply a new value for the account value
    /// in views like the ``SignupForm``.
    ///
    /// - Note: There are default implementations for some standard types that all provide a ``InitialValue/empty(_:)`` value.
    static var initialValue: InitialValue<Value> { get }

    /// A unique identifier for an account key.
    ///
    /// - Note: A default implementation is provided.
    static var id: ObjectIdentifier { get }
}


extension AccountKey {
    /// A unique identifier for an account key. Bound to the process lifetime.
    public static var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }

    /// Default implementation falling back to the Swift type name.
    public static var identifier: String {
        "\(Self.self)"
    }

    static var isRequired: Bool {
        self is any RequiredAccountKey.Type
    }
}


extension AccountKey where Value: StringProtocol {
    /// Default initial value for `String` values.
    public static var initialValue: InitialValue<Value> {
        .empty("")
    }
}


extension AccountKey where Value: AdditiveArithmetic {
    /// Default initial value for numeric values.
    public static var initialValue: InitialValue<Value> {
        // this catches all the numeric types
        .empty(.zero)
    }
}


extension AccountKey where Value: ExpressibleByArrayLiteral {
    /// Default initial value for `Array` values.
    public static var initialValue: InitialValue<Value> {
        .empty([])
    }
}


extension AccountKey where Value: ExpressibleByDictionaryLiteral {
    /// Default initial value for `Dictionary` values.
    public static var initialValue: InitialValue<Value> {
        .empty([:])
    }
}
