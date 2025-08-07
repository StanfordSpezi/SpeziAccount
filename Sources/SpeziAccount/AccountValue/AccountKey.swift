//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import RuntimeAssertions
import SpeziFoundation
import SwiftUI


#if compiler(<6.2)
/// Pre Swift 6.2 typealias for `SendableMetatype` that resolves as `Any` to avoid larger `#if` statements in the code base.
public typealias SendableMetatype = Any
#endif

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
///     `Codable` conformance is required such that ``AccountStorageProvider``s
///     can easily store arbitrarily defined account values.
///
/// ## Topics
///
/// ### Shared Repository
/// - ``AccountAnchor``
/// - ``AccountStorage``
public protocol AccountKey: KnowledgeSource<AccountAnchor>, SendableMetatype where Value: Sendable, Value: Equatable, Value: Codable {
    /// The view that is used to display a value for this account key.
    ///
    /// This view is used in views like the ``AccountOverview`` to display the current value for this `AccountKey`.
    /// - Note: Refer to the <doc:Adding-new-Account-Values> article for a list of ``DataDisplayView`` that are automatically provided.
    associatedtype DataDisplay: DataDisplayView<Value>
    
    /// The view that is used to enter a value for this account value.
    ///
    /// This view is used in views like the ``SignupForm`` to enter the account value.
    /// - Note: Refer to the <doc:Adding-new-Account-Values> article for a list of ``DataDisplayView`` that are automatically provided.
    associatedtype DataEntry: DataEntryView<Value>
    
    /// The user-visible, localized name of the account key.
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

    /// Options to configure the behavior of the account key.
    ///
    /// Refer to ``AccountKeyOptions`` for more information.
    static var options: AccountKeyOptions { get }

    /// The initial value that is used when supplying a new account value.
    ///
    /// An empty value (e.g., an empty `String`) is required when the user is asked to supply a new value for the account value
    /// in views like the ``SignupForm``.
    ///
    /// - Note: There are default implementations for some standard types that all provide a ``InitialValue/empty(_:)`` value.
    static var initialValue: InitialValue<Value> { get }
}


extension AccountKey {
    /// A unique identifier for an account key. Bound to the process lifetime.
    static var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }

    static var isRequired: Bool {
        self is any RequiredAccountKey.Type
    }

    /// A ``AccountKeyCategory/credentials`` key that is not meant to be modified in
    /// the `SecurityOverview` section in the ``AccountOverview``.
    static var isHiddenCredential: Bool {
        self == AccountKeys.accountId || self == AccountKeys.userId
    }
}


extension AccountKey where Value: StringProtocol {
    /// Default initial value for `String` values.
    public static var initialValue: InitialValue<Value> {
        .empty("")
    }
}


extension AccountKey where Value == Bool {
    /// Default initial value for `Bool` values.
    public static var initialValue: InitialValue<Value> {
        .default(false)
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
