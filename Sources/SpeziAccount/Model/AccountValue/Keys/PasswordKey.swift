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

    public static let name = LocalizedStringResource("UP_PASSWORD", bundle: .atURL(from: .module))

    public static let category: AccountValueCategory = .credentials
}


extension AccountValueKeys {
    /// The password ``AccountValueKey`` metatype.
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

        @EnvironmentObject private var dataEntryConfiguration: DataEntryConfiguration
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


enum PasswordFieldType: EnvironmentKey, CustomLocalizedStringResourceConvertible {
    /// Standard password field
    case password
    /// New password field
    case new
    /// Password repeat field
    case `repeat`

    // TODO handle focus state?

    static let defaultValue: PasswordFieldType = .password
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .password:
            return PasswordKey.name
        case .new:
            return .init("NEW_PASSWORD", bundle: .atURL(from: .module))
        case .repeat:
            return .init("REPEAT_PASSWORD", bundle: .atURL(from: .module))
        }
    }
}


extension EnvironmentValues {
    var passwordFieldType: PasswordFieldType {
        get {
            self[PasswordFieldType.self]
        }
        set {
            self[PasswordFieldType.self] = newValue
        }
    }
}
