//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SpeziViews
import SwiftUI


extension AccountDetails {
    /// The password of a user.
    ///
    /// This transports the plain-text password of a user account.
    /// - Note: This account value is only ever present in the ``SignupDetails`` and ``ModifiedAccountDetails`` and
    ///     never present in any of the other ``AccountValues``.
    @AccountKey(name: LocalizedStringResource("UP_PASSWORD", bundle: .atURL(from: .module)), category: .credentials, as: String.self)
    public var password: String?
}


@KeyEntry(\.password)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier

// MARK: - UI

extension AccountDetails.__Key_password {
    public struct DataEntry: DataEntryView {
        @Environment(\.accountViewType)
        private var accountViewType
        @Environment(\.passwordFieldType)
        private var fieldType
        @Environment(ValidationEngine.self)
        private var validation

        @Binding private var password: Value


        public init(_ value: Binding<Value>) {
            self._password = value
        }

        public var body: some View {
            switch accountViewType {
            case .signup, .none:
                VerifiableTextField(fieldType.localizedStringResource, text: $password, type: .secure)
                    #if targetEnvironment(simulator)
                    // we do not use `.newPassword` within simulator builds to not interfer with UI tests
                    .textContentType(.password)
                    #else
                    .textContentType(.newPassword)
                    #endif
                    .disableFieldAssistants()
            case .overview: // display description labels in the PasswordChangeSheet (as we have two password fields)
                DescriptionGridRow {
                    Text(fieldType.localizedStringResource)
                } content: {
                    SecureField(text: $password) {
                        Text(fieldType.localizedPrompt)
                    }
                        #if targetEnvironment(simulator)
                        // we do not use `.newPassword` within simulator builds to not interfer with UI tests
                        .textContentType(.password)
                        #else
                        .textContentType(.newPassword)
                        #endif
                        .disableFieldAssistants()
                }

                GridValidationStateFooter(validation.displayedValidationResults)
            }
        }
    }
}
