//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// A DataEntry and DataDisplay view that is empty and accepts never values.
public struct _EmptyDataView: DataDisplayView, DataEntryView { // swiftlint:disable:this type_name
    public typealias Value = Never

    public var body: some View {
        EmptyView()
    }

    public init(_ value: Never) {}

    public init(_ value: Binding<Never>) {}
}


/// Create a new `AccountKey`.
///
/// Create a new ``AccountKey`` by declaring an extension to the ``AccountDetails``.
///
/// ```swift
/// extension AccountDetails {
///     @AccountKey(name: "Biography", category: .personalDetails, as: String.self)
///     var biography: String?
/// }
/// ```
///
/// - Important: Refer to the <doc:Adding-new-Account-Values> article for a detailed guide on how to declare a ``KeyEntry(_:)`` and
///     customizing the user interface.
///
/// - Parameters:
///   - id: A stable, string-based identifier that is used by storage providers.
///   - name: The user-visible, localized name of the account key.
///   - category: The category the account key belongs to. It will be used to visually group similar account details together.
///   - value: The value type. This type must be equal to the type annotation of the property.
///   - initial: The initial value used when entering
///   - displayView: A customized ``DataDisplayView`` that is used to display existing values of this account key.
///   - entryView: A customized ``DataEntryView`` that is used to enter new or edit existing values of this account key.
@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    id: String? = nil,
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as value: Value.Type,
    initial: InitialValue<Value>,
    displayView: DataDisplay.Type = _EmptyDataView.self,
    entryView: DataEntry.Type = _EmptyDataView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


/// Create a new `AccountKey`.
///
/// Create a new ``AccountKey`` by declaring an extension to the ``AccountDetails``.
/// This overload provides a default ``InitialValue/empty(_:)`` for `String` values.
///
/// ```swift
/// extension AccountDetails {
///     @AccountKey(name: "Biography", category: .personalDetails, as: String.self)
///     var biography: String?
/// }
/// ```
///
/// - Important: Refer to the <doc:Adding-new-Account-Values> article for a detailed guide on how to declare a ``KeyEntry(_:)`` and
///     customizing the user interface.
///
/// - Parameters:
///   - id: A stable, string-based identifier that is used by storage providers.
///   - name: The user-visible, localized name of the account key.
///   - category: The category the account key belongs to. It will be used to visually group similar account details together.
///   - value: The value type. This type must be equal to the type annotation of the property.
///   - displayView: A customized ``DataDisplayView`` that is used to display existing values of this account key.
///   - entryView: A customized ``DataEntryView`` that is used to enter new or edit existing values of this a
@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: StringProtocol, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    id: String? = nil,
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as value: Value.Type,
    displayView: DataDisplay.Type = _EmptyDataView.self,
    entryView: DataEntry.Type = _EmptyDataView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


/// Create a new `AccountKey`.
///
/// Create a new ``AccountKey`` by declaring an extension to the ``AccountDetails``.
/// This overload provides a default ``InitialValue/default(_:)`` for `Bool` values.
///
/// ```swift
/// extension AccountDetails {
///     @AccountKey(name: "Public Profile", as: Bool.self)
///     var isPublicProfile: Bool?
/// }
/// ```
///
/// - Important: Refer to the <doc:Adding-new-Account-Values> article for a detailed guide on how to declare a ``KeyEntry(_:)`` and
///     customizing the user interface.
///
/// - Parameters:
///   - id: A stable, string-based identifier that is used by storage providers.
///   - name: The user-visible, localized name of the account key.
///   - category: The category the account key belongs to. It will be used to visually group similar account details together.
///   - value: The value type. This type must be equal to the type annotation of the property.
///   - displayView: A customized ``DataDisplayView`` that is used to display existing values of this account key.
///   - entryView: A customized ``DataEntryView`` that is used to enter new or edit existing values of this a
@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    id: String? = nil,
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as value: Bool.Type,
    displayView: DataDisplay.Type = _EmptyDataView.self,
    entryView: DataEntry.Type = _EmptyDataView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


/// Create a new `AccountKey`.
///
/// Create a new ``AccountKey`` by declaring an extension to the ``AccountDetails``.
/// This overload provides a default ``InitialValue/empty(_:)`` for `Numeric` values.
///
/// ```swift
/// extension AccountDetails {
///     @AccountKey(name: "Steps Goal", as: Int.self)
///     var stepsGoal: Int?
/// }
/// ```
///
/// - Important: Refer to the <doc:Adding-new-Account-Values> article for a detailed guide on how to declare a ``KeyEntry(_:)`` and
///     customizing the user interface.
///
/// - Parameters:
///   - id: A stable, string-based identifier that is used by storage providers.
///   - name: The user-visible, localized name of the account key.
///   - category: The category the account key belongs to. It will be used to visually group similar account details together.
///   - value: The value type. This type must be equal to the type annotation of the property.
///   - displayView: A customized ``DataDisplayView`` that is used to display existing values of this account key.
///   - entryView: A customized ``DataEntryView`` that is used to enter new or edit existing values of this a
@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: AdditiveArithmetic, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    id: String? = nil,
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as value: Value.Type,
    displayView: DataDisplay.Type = _EmptyDataView.self,
    entryView: DataEntry.Type = _EmptyDataView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


/// Create a new `AccountKey`.
///
/// Create a new ``AccountKey`` by declaring an extension to the ``AccountDetails``.
/// This overload provides a default ``InitialValue/empty(_:)`` for `Array` values.
///
/// ```swift
/// extension AccountDetails {
///     @AccountKey(name: "Address", category: .personalDetails, as: [String].self)
///     var address: [String]?
/// }
/// ```
///
/// - Important: Refer to the <doc:Adding-new-Account-Values> article for a detailed guide on how to declare a ``KeyEntry(_:)`` and
///     customizing the user interface.
///
/// - Parameters:
///   - id: A stable, string-based identifier that is used by storage providers.
///   - name: The user-visible, localized name of the account key.
///   - category: The category the account key belongs to. It will be used to visually group similar account details together.
///   - value: The value type. This type must be equal to the type annotation of the property.
///   - displayView: A customized ``DataDisplayView`` that is used to display existing values of this account key.
///   - entryView: A customized ``DataEntryView`` that is used to enter new or edit existing values of this a
@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: ExpressibleByArrayLiteral, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    id: String? = nil,
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as value: Value.Type,
    displayView: DataDisplay.Type = _EmptyDataView.self,
    entryView: DataEntry.Type = _EmptyDataView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


/// Create a key entry in `AccountKeys`.
///
/// This macro creates a entry in the ``AccountKeys`` collection for a given ``AccountKey``.
///
/// Assuming you have a `genderIdentity` account key defined on `AccountDetails`, you can use the macro like in the following:
/// ```swift
/// @KeyEntry(\.genderIdentity)
/// extension AccountKeys {}
/// ```
///
/// - Note: Just add a `public` modifier to the extension to make the entry `public`.
///
/// - Parameter key: The KeyPath to the AccountKey defined on the ``AccountDetails``.
@attached(member, names: arbitrary)
public macro KeyEntry<Value>(
    _ key: KeyPath<AccountDetails, Value>
) = #externalMacro(module: "SpeziAccountMacros", type: "KeyEntryMacro")
