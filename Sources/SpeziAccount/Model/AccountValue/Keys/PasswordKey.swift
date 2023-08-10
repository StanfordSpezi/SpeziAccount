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
/// This ``AccountValueKey`` transports the plain-text password of a user account.
/// - Note: This account value is only present in the ``SignupDetails`` and never present in the ``AccountDetails``.
public struct PasswordKey: RequiredAccountValueKey {
    public typealias Value = String

    public static let category: AccountValueCategory = .credentials
}


extension AccountValueKeys {
    /// The password ``AccountValueKey``.
    ///
    /// - Note: This account value is only present in the ``SignupDetails``.
    public var password: PasswordKey.Type {
        PasswordKey.self // TODO this is accessible everywhere, make something specific for signupdetails?
    }
}


extension SignupDetails {
    /// Access the password of a user in the ``SignupDetails``.
    public var password: PasswordKey.Value {
        storage[PasswordKey.self]
    }
}


// MARK: - UI
extension PasswordKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = PasswordKey

        @Environment(\.dataEntryConfiguration)
        var dataEntryConfiguration: DataEntryConfiguration

        @Binding private var password: Value


        public init(_ value: Binding<Value>) {
            self._password = value
        }

        public var body: some View {
            VerifiableTextField("UP_PASSWORD".localized(.module), text: $password, type: .secure)
                .textContentType(.newPassword)
                .disableFieldAssistants()
        }
    }
}
