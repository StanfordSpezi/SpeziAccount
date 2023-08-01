//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// TODO write a article "how to create new account value keys"
//  - consider: required vs. optional;
//  - declare protocol conformance (Valu, Category, Anchor!) -> link to shared repository
//  - extension to AccountValueKeys struct => if you should be able to modify it?!
//  - AccountValueStorageContainer extension (or ModifiableAccountValueStorageContainer?; or SignupRequest or AccountDetails?)

/// A ``RequiredAccountValueKey`` that models a string-based user identifier.
///
/// The `userId` is used to uniquely identify a given account. The value might carry
/// additional semantics. For example, the `userId` might, at the same time, be the primary email address
/// of the user. Such semantics can be controlled by the ``AccountService``
/// using the ``UserIdType`` configuration. TODO can the user also control this?
///
/// - Note: You may also refer to the ``EmailAddressKey`` to query the email address of an account.
public struct UserIdKey: RequiredAccountValueKey { // TODO introduce required values after the fact?
    public typealias Value = String

    public static let signupCategory: SignupCategory = .credentials
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

// TODO one might not change the user id!
extension ModifiableAccountValueStorageContainer {
    /// Provides access to the value of the ``UserIdKey`` of an account.
    public var userId: UserIdKey.Value {
        get {
            storage[UserIdKey.self]
        }
        set {
            storage[UserIdKey.self] = newValue
        }
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
                .fieldConfiguration(userIdConfiguration.fieldType)
                .disableFieldAssistants()
        }
    }
}
