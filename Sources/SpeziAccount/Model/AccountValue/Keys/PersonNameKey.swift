//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


public struct PersonNameKey: RequiredAccountValueKey {
    public typealias Value = PersonNameComponents

    public static let signupCategory: SignupCategory = .name

    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        // TODO person name components default init!
        GeneralizedDataEntryView(initialValue: .init())
    }
}


extension AccountValueKeys {
    public var name: PersonNameKey.Type {
        PersonNameKey.self
    }
}


extension AccountValueStorageContainer {
    public var name: PersonNameKey.Value {
        storage[PersonNameKey.self]
    }
}


// TODO define update strategy => write value and then call account service?
extension ModifiableAccountValueStorageContainer {
    public var name: PersonNameKey.Value {
        get {
            storage[PersonNameKey.self]
        }
        set {
            storage[PersonNameKey.self] = newValue
        }
    }
}


// MARK: - UI
extension PersonNameKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = PersonNameKey

        @Environment(\.dataEntryConfiguration)
        var dataEntryConfiguration: DataEntryConfiguration

        @Binding private var name: Value

        public init(_ value: Binding<Value>) {
            self._name = value
        }

        public var body: some View {
            NameFields(
                name: $name,
                givenNameField: FieldLocalizationResource(
                    title: "UAP_SIGNUP_GIVEN_NAME_TITLE",
                    placeholder: "UAP_SIGNUP_GIVEN_NAME_PLACEHOLDER",
                    bundle: .module
                ),
                givenNameFieldIdentifier: Key.focusState,
                familyNameField: FieldLocalizationResource(
                    title: "UAP_SIGNUP_FAMILY_NAME_TITLE",
                    placeholder: "UAP_SIGNUP_FAMILY_NAME_PLACEHOLDER",
                    bundle: .module
                ),
                familyNameFieldIdentifier: Key.focusState + "-familyName",
                focusedState: dataEntryConfiguration.focusedField
            )
        }
    }
}
