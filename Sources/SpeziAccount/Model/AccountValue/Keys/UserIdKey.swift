//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A string-based, unique user identifier.
///
/// The `userId` is used to uniquely identify a given account. The value might carry
/// additional semantics. For example, the `userId` might, at the same time, be the primary email address
/// of the user. Such semantics can be controlled by the ``AccountService``
/// using the ``UserIdType`` configuration. TODO can the user also control this?
///
/// - Note: You may also refer to the ``EmailAddressKey`` to query the email address of an account.
public struct UserIdKey: RequiredAccountValueKey { // TODO introduce required values after the fact?
    public typealias Value = String

    public static let category: AccountValueCategory = .credentials
}


extension AccountValueKeys {
    /// Refer to the ``UserIdKey`` for documentation.
    public var userId: UserIdKey.Type {
        UserIdKey.self
    }
}


extension AccountValueStorageContainer {
    /// Provides access to the value of the ``UserIdKey`` of an account.
    public var userId: UserIdKey.Value {
        storage[UserIdKey.self]
    }
}


// MARK: - UI
extension UserIdKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = UserIdKey

        @Environment(\.dataEntryConfiguration)
        var dataEntryConfiguration: DataEntryConfiguration

        @Binding var userId: Value


        private var userIdConfiguration: UserIdConfiguration {
            dataEntryConfiguration.serviceConfiguration.userIdConfiguration
        }


        public init(_ value: Binding<Value>) {
            self._userId = value
        }

        public var body: some View {
            VerifiableTextField(userIdConfiguration.idType.localizedStringResource, text: $userId)
                .textContentType(userIdConfiguration.textContentType)
                .keyboardType(userIdConfiguration.keyboardType)
                .disableFieldAssistants()
        }
    }
}
