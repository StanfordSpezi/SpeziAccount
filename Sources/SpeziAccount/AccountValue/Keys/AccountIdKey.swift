//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The primary, unique, stable and typically internal identifier for an user account.
///
/// The `accountId` is used to uniquely identify a given account at any point in time.
/// While the ``UserIdKey`` is typically the primary user-facing identifier and might change, the `accountId` is internal
/// and a stable account identifier (e.g., to associate stored data to the account).
///
/// - Note: You should aim to use a string-based identifier, that doesn't contain any special characters to allow
///     for maximum compatibility with other components.
///
/// ### Configuration
/// As a user you don't need to worry about manually configuring the `accountId`. As it is not user-facing,
/// you don't have to do anything.
///
/// As an ``AccountService`` you are required to supply the `accountId` for every ``AccountDetails`` you provide
/// to ``Account/supplyUserDetails(_:isNewUser:)``. Further, if you supply a ``SupportedAccountKeys/exactly(_:)``
/// configuration as part of your ``AccountServiceConfiguration``, make sure to include the `accountId` there as well.
public struct AccountIdKey: RequiredAccountKey {
    public typealias Value = String

    public static let name = LocalizedStringResource("ACCOUNT_ID", bundle: .atURL(from: .module))

    public static let category: AccountKeyCategory = .credentials
}


extension AccountKeys {
    /// The accountId ``AccountIdKey``
    public var accountId: AccountIdKey.Type {
        AccountIdKey.self
    }
}


extension AccountValues {
    /// Access the account id of a user (see ``AccountIdKey``).
    public var accountId: String {
        storage[AccountIdKey.self]
    }
}


extension AccountIdKey {
    public struct DataDisplay: DataDisplayView {
        public typealias Key = AccountIdKey

        public var body: some View {
            Text("The internal account identifier is not meant to be user facing!")
        }

        public init(_ value: Value) {}
    }

    public struct DataEntry: DataEntryView {
        public typealias Key = AccountIdKey

        public var body: some View {
            Text("The internal account identifier is meant to be generated!")
        }

        public init(_ value: Binding<Key.Value>) {}
    }
}
