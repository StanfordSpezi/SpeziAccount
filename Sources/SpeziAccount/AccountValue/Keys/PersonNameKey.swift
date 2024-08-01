//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SpeziValidation
import SpeziViews
import SwiftUI


private struct DisplayView: DataDisplayView {
    private let value: PersonNameComponents

    var body: some View {
        ListRow(AccountKeys.name.name) {
            Text(value.formatted(.name(style: .long)))
        }
    }

    init(_ value: PersonNameComponents) {
        self.value = value
    }
}


private struct EntryView: DataEntryView {
    @Environment(Account.self)
    private var account

    @ValidationState private var givenNameValidation
    @ValidationState private var familyNameValidation

    @Binding private var name: PersonNameComponents

    private var nameIsRequired: Bool {
        account.configuration.name?.requirement == .required
    }

    private var validationRule: ValidationRule {
        nameIsRequired ? .nonEmpty : .acceptAll
    }

    var body: some View {
        Grid(horizontalSpacing: 16) {
            NameFieldRow(name: $name, for: \.givenName) {
                Text("UAP_SIGNUP_GIVEN_NAME_TITLE", bundle: .module)
            } label: {
                Text("UAP_SIGNUP_GIVEN_NAME_PLACEHOLDER", bundle: .module)
            }
            .validate(input: name.givenName ?? "", rules: validationRule)
            .receiveValidation(in: $givenNameValidation)
            .focusOnTap() // ensure field receives focus when tapping on the description label

            GridValidationStateFooter(givenNameValidation.allDisplayedValidationResults)

            Divider()
                .gridCellUnsizedAxes(.horizontal)

            NameFieldRow(name: $name, for: \.familyName) {
                Text("UAP_SIGNUP_FAMILY_NAME_TITLE", bundle: .module)
            } label: {
                Text("UAP_SIGNUP_FAMILY_NAME_PLACEHOLDER", bundle: .module)
            }
            .validate(input: name.familyName ?? "", rules: validationRule)
            .receiveValidation(in: $familyNameValidation)
            .focusOnTap() // ensure field receives focus when tapping on the description label

            GridValidationStateFooter(familyNameValidation.allDisplayedValidationResults)
        }
        .environment(\.validationConfiguration, .considerNoInputAsValid)
        .onChange(of: givenNameValidation) {
            print("given Name: \(givenNameValidation)")
        }
        .onChange(of: familyNameValidation) {
            print("family Name: \(familyNameValidation)")
        }
    }


    init(_ value: Binding<PersonNameComponents>) {
        self._name = value
    }
}


extension AccountDetails {
    /// The name of a user.
    @AccountKey(
        id: "PersonNameKey", // backwards compatibility with 1.0 releases
        name: LocalizedStringResource("NAME", bundle: .atURL(from: .module)),
        category: .name,
        as: PersonNameComponents.self,
        initial: .empty(PersonNameComponents()),
        displayView: DisplayView.self,
        entryView: EntryView.self
    )
    public var name: PersonNameComponents?
}


@KeyEntry(\.name)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier
