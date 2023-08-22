//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziViews
import SwiftUI


/// The name of a user.
public struct PersonNameKey: AccountKey {
    public typealias Value = PersonNameComponents

    public static let name = LocalizedStringResource("NAME", bundle: .atURL(from: .module))

    public static let category: AccountKeyCategory = .name
}


extension AccountKeys {
    /// The name ``AccountKey`` metatype.
    public var name: PersonNameKey.Type {
        PersonNameKey.self
    }
}


extension AccountValues {
    /// Access the name of a user.
    public var name: PersonNameComponents? {
        storage[PersonNameKey.self]
    }
}


// MARK: - UI

extension PersonNameKey {
    public struct DataDisplay: DataDisplayView {
        public typealias Key = PersonNameKey

        private let value: PersonNameComponents

        public var body: some View {
            Text(Key.name)
            Spacer()
            Text(value.formatted(.name(style: .long)))
                .foregroundColor(.secondary)
        }


        public init(_ value: PersonNameComponents) {
            self.value = value
        }
    }
}

extension PersonNameKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = PersonNameKey


        private static let givenNameRule = ValidationRule(
            copy: .nonEmpty,
            message: .init("VALIDATION_RULE_GIVEN_NAME_EMPTY", bundle: .atURL(from: .module))
        )

        private static let familyNameRule = ValidationRule(
            copy: .nonEmpty,
            message: .init("VALIDATION_RULE_FAMILY_NAME_EMPTY", bundle: .atURL(from: .module))
        )


        @EnvironmentObject private var account: Account
        @EnvironmentObject private var dataEntryConfiguration: DataEntryConfiguration
        @EnvironmentObject private var closures: ValidationClosures<String>

        @StateObject private var validationGivenName = ValidationEngine(rules: givenNameRule)
        @StateObject private var validationFamilyName = ValidationEngine(rules: familyNameRule)

        @Binding private var name: Value

        private var nameIsRequired: Bool {
            account.configuration[Key.self]?.requirement == .required
        }

        private var givenNameField: String {
            Key.focusState
        }

        private var familyNameField: String {
            Key.focusState + "-familyName"
        }

        public var body: some View {
            if nameIsRequired {
                closures.register(running: validationGivenName, for: givenNameField, validation: onGivenNameSubmission)
                closures.register(running: validationFamilyName, for: familyNameField, validation: onFamilyNameSubmission)
            }

            NameFields(
                name: $name,
                givenNameField: FieldLocalizationResource(
                    title: "UAP_SIGNUP_GIVEN_NAME_TITLE",
                    placeholder: "UAP_SIGNUP_GIVEN_NAME_PLACEHOLDER",
                    bundle: .module
                ),
                givenNameFieldIdentifier: givenNameField,
                familyNameField: FieldLocalizationResource(
                    title: "UAP_SIGNUP_FAMILY_NAME_TITLE",
                    placeholder: "UAP_SIGNUP_FAMILY_NAME_PLACEHOLDER",
                    bundle: .module
                ),
                familyNameFieldIdentifier: familyNameField,
                focusedState: dataEntryConfiguration.focusedField
            )
                .onChange(of: name.familyName) { newValue in
                    submit(value: newValue, to: \.validationGivenName)
                }
                .onChange(of: name.givenName) { newValue in
                    submit(value: newValue, to: \.validationFamilyName)
                }

            HStack {
                ValidationResultsView(results: validationGivenName.displayedValidationResults + validationFamilyName.displayedValidationResults)
                Spacer()
            }
        }


        public init(_ value: Binding<Value>) {
            self._name = value
        }

        private func submit(value: String?, to validationEngine: KeyPath<Self, ValidationEngine>) {
            guard nameIsRequired else {
                return
            }

            self[keyPath: validationEngine].submit(input: value ?? "", debounce: true)
        }

        private func onGivenNameSubmission() -> ValidationResult {
            validationGivenName.runValidation(input: name.givenName ?? "")
            return validationGivenName.inputValid ? .success : .failed
        }

        private func onFamilyNameSubmission() -> ValidationResult {
            validationFamilyName.runValidation(input: name.familyName ?? "")
            return validationFamilyName.inputValid ? .success : .failed
        }
    }
}


extension PersonNameComponents: DefaultInitializable {}
