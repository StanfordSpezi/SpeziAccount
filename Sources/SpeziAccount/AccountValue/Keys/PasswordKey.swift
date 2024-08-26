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


private struct ConfigureView: SecurityView {
    typealias Value = String

    @Environment(Account.self)
    private var account

    @State private var presentingPasswordSheet = false

    private var label: Text {
        if account.details?.configuredCredentials.contains(where: { $0 == AccountKeys.password }) == true {
            Text("CHANGE_PASSWORD", bundle: .module)
        } else {
            Text("Setup Password", bundle: .module)
        }
    }

    var body: some View {
        Button(action: {
            presentingPasswordSheet = true
        }) {
            label
        }
            .sheet(isPresented: $presentingPasswordSheet) {
                PasswordChangeSheet()
            }
    }

    init() { // TODO: does that make sense?
        // password will be never present, configuring/changing password is done via other mechanisms
    }
}


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
        name: LocalizedStringResource("UP_PASSWORD", bundle: .atURL(from: .module)),
        category: .credentials,
        as: String.self,
        displayView: ConfigureView.self,
        entryView: EntryView.self
    )
    public var password: String?
}


@KeyEntry(\.password)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier
