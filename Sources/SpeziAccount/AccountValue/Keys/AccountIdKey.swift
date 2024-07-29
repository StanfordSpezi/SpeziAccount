//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


extension AccountDetails {
    /// The primary, unique, stable and typically internal identifier for an user account.
    ///
    /// The `accountId` is used to uniquely identify a given account at any point in time.
    /// While the ``userId`` is typically the primary user-facing identifier and might change, the `accountId` is internal
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
    @AccountKey(name: LocalizedStringResource("ACCOUNT_ID", bundle: .atURL(from: .module)), category: .credentials, initial: .empty(""))
    public var accountId: String
    // TODO: remove empty initial!
}


@KeyEntry(\.accountId)
public extension AccountKeys { // swiftlint:disable:this no_extension_access_modifier
}


// TODO: find a better way to specify this?
extension AccountDetails.__Key_accountId {
    public struct DataDisplay: DataDisplayView {
        public var body: some View {
            Text("The internal account identifier is not meant to be user facing!", comment: "Pure debug message, no need to translate.")
        }


        public init(_ value: Value) {}
    }

    public struct DataEntry: DataEntryView {
        public var body: some View {
            Text("The internal account identifier is meant to be generated!", comment: "Pure debug message, no need to translate.")
        }

        public init(_ value: Binding<String>) {}
    }
}
