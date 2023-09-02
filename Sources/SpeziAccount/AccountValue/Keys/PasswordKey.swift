//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The password of a user account.
///
/// This ``AccountKey`` transports the plain-text password of a user account.
/// - Note: This account value is only ever present in the ``SignupDetails`` and ``ModifiedAccountDetails`` and
///     never present in any of the other ``AccountValues``.
///
/// ## Topics
///
/// ### Password UI
///
/// - ``PasswordFieldType``
public struct PasswordKey: RequiredAccountKey {
    public typealias Value = String

    public static let name = LocalizedStringResource("UP_PASSWORD", bundle: .atURL(from: .module))

    public static let category: AccountKeyCategory = .credentials
}


extension AccountKeys {
    /// The password ``AccountKey`` metatype.
    ///
    /// - Note: This account value is only present in the ``SignupDetails``.
    public var password: PasswordKey.Type {
        PasswordKey.self
    }
}


extension SignupDetails {
    /// Access the password of a user in the ``SignupDetails``.
    public var password: String {
        storage[PasswordKey.self]
    }
}

extension ModifiedAccountDetails {
    /// Access the changed password of a user in the ``ModifiedAccountDetails``.
    public var password: String? {
        storage[PasswordKey.self]
    }
}


// MARK: - UI

extension PasswordKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = PasswordKey

        @Environment(\.passwordFieldType) private var fieldType

        @Binding private var password: Value


        public init(_ value: Binding<Value>) {
            self._password = value
        }

        public var body: some View {
            VerifiableTextField(fieldType.localizedStringResource, text: $password, type: .secure)
                .textContentType(.newPassword)
                .disableFieldAssistants()
        }
    }
}
