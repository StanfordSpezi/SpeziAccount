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


/// The name of a user.
public struct PersonNameKey: AccountKey {
    public typealias Value = PersonNameComponents

    public static let name = LocalizedStringResource("NAME", bundle: .atURL(from: .module))

    public static let category: AccountKeyCategory = .name

    public static let initialValue: InitialValue<Value> = .empty(PersonNameComponents())
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
            SimpleTextRow(name: Key.name) {
                Text(value.formatted(.name(style: .long)))
            }
        }


        public init(_ value: PersonNameComponents) {
            self.value = value
        }
    }
}

extension PersonNameKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = PersonNameKey


        @EnvironmentObject private var account: Account
        @EnvironmentObject private var focusState: FocusStateObject

        @ValidationState(String.self) private var givenNameValidation
        @ValidationState(String.self) private var familyNameValidation

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
        
        private var validationRule: ValidationRule {
            nameIsRequired ? .nonEmpty : .acceptAll
        }

        public var body: some View {
            Grid(horizontalSpacing: 16) {
                NameFieldRow(name: $name, for: \.givenName) {
                    Text("UAP_SIGNUP_GIVEN_NAME_TITLE", bundle: .module)
                } label: {
                    Text("UAP_SIGNUP_GIVEN_NAME_PLACEHOLDER", bundle: .module)
                }
                    .focused(focusState.projectedValue, equals: givenNameField)
                    .validate(input: name.givenName ?? "", field: givenNameField, rules: validationRule)
                    .receiveValidation(in: $givenNameValidation)

                
                // TODO: make this its own UI component!
                if givenNameValidation.isDisplayingValidationErrors { // otherwise we have some weird layout issues
                    HStack {
                        ValidationResultsView(results: givenNameValidation.allDisplayedValidationResults)
                        Spacer()
                    }
                }

                Divider()
                    .gridCellUnsizedAxes(.horizontal)

                NameFieldRow(name: $name, for: \.familyName) {
                    Text("UAP_SIGNUP_FAMILY_NAME_TITLE", bundle: .module)
                } label: {
                    Text("UAP_SIGNUP_FAMILY_NAME_PLACEHOLDER", bundle: .module)
                }
                    .focused(focusState.projectedValue, equals: familyNameField)
                    .validate(input: name.familyName ?? "", field: familyNameField, rules: validationRule)
                    .receiveValidation(in: $familyNameValidation)

                if familyNameValidation.isDisplayingValidationErrors { // otherwise we have some weird layout issues
                    HStack {
                        ValidationResultsView(results: familyNameValidation.allDisplayedValidationResults)
                        Spacer()
                    }
                }
            }
                .environment(\.validationConfiguration, .considerNoInputAsValid)
        }


        public init(_ value: Binding<Value>) {
            self._name = value
        }
    }
}
