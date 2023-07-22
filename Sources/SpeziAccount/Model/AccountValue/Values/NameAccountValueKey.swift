//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


public struct NameAccountValueKey: RequiredAccountValueKey {
    public typealias Value = PersonNameComponents

    public static let signupCategory: SignupCategory = .name

    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        // TODO person name components default init!
        GeneralizedDataEntryView(initialValue: .init())
    }
}


extension AccountValueKeys {
    public var name: NameAccountValueKey.Type {
        NameAccountValueKey.self
    }
}


extension AccountValueStorageContainer {
    public var name: NameAccountValueKey.Value {
        storage[NameAccountValueKey.self]
    }
}


// TODO define update strategy => write value and then call account service?
extension ModifiableAccountValueStorageContainer {
    public var name: NameAccountValueKey.Value {
        get {
            storage[NameAccountValueKey.self]
        }
        set {
            storage[NameAccountValueKey.self] = newValue
        }
    }
}


// MARK: - UI
extension NameAccountValueKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = NameAccountValueKey

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
                givenNameFieldIdentifier: Key.focusState + "-givenName",
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
