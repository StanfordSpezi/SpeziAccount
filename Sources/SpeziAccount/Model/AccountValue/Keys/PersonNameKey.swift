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
public struct PersonNameKey: RequiredAccountValueKey {
    public typealias Value = PersonNameComponents

    public static let category: AccountValueCategory = .name
}


extension AccountValueKeys {
    /// The name ``AccountValueKey`` metatype.
    public var name: PersonNameKey.Type {
        PersonNameKey.self
    }
}


extension AccountValueStorageContainer {
    /// Access the name of a user.
    public var name: PersonNameComponents {
        storage[PersonNameKey.self]
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


extension PersonNameComponents: DefaultInitializable {}
