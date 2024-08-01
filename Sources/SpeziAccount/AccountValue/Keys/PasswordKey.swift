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


private struct EntryView: DataEntryView {
    @Environment(\.accountViewType)
    private var accountViewType
    @Environment(\.passwordFieldType)
    private var fieldType
    @Environment(ValidationEngine.self)
    private var validation

    @Binding private var password: String

    var body: some View {
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


    init(_ value: Binding<String>) {
        self._password = value
    }
}


extension AccountDetails {
    /// The password of a user.
    ///
    /// This transports the plain-text password of a user account.
    /// - Note: This account value is only present if the ``AccountDetails`` transport are part of modifications (e.g. in ``AccountModifications``) or transport
    ///     signup details (e.g., using ``SignupForm``). `SpeziAccount` will never store the user's password in plain-text.
    @AccountKey(
        id: "PasswordKey", // backwards compatibility with 1.0 releases
        name: LocalizedStringResource("UP_PASSWORD", bundle: .atURL(from: .module)),
        category: .credentials,
        as: String.self,
        entryView: EntryView.self
    )
    public var password: String?
}


@KeyEntry(\.password)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier
