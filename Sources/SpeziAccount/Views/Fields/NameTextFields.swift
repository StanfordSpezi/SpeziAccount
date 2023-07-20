//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NameTextFields: View {
    private static let defaultGivenNameLocalization = FieldLocalizationResource(
        title: "UAP_SIGNUP_GIVEN_NAME_TITLE",
        placeholder: "UAP_SIGNUP_GIVEN_NAME_PLACEHOLDER",
        bundle: .module
    )
    private static let defaultFamilyNameLocalization = FieldLocalizationResource(
        title: "UAP_SIGNUP_FAMILY_NAME_TITLE",
        placeholder: "UAP_SIGNUP_FAMILY_NAME_PLACEHOLDER",
        bundle: .module
    )

    private let givenNameLocalization: FieldLocalizationResource
    private let familyNameLocalization: FieldLocalizationResource

    @Binding private var name: PersonNameComponents
    @FocusState private var focusedField: AccountInputFields?
    
    
    var body: some View {
        // TODO are there name fields without a grid?
        SpeziViews.NameFields(
            name: $name,
            givenNameField: givenNameLocalization,
            givenNameFieldIdentifier: AccountInputFields.givenName,
            familyNameField: familyNameLocalization,
            familyNameFieldIdentifier: AccountInputFields.familyName,
            focusedState: _focusedField
        )
    }
    
    
    init(
        name: Binding<PersonNameComponents>,
        givenName: FieldLocalizationResource = defaultGivenNameLocalization,
        familyName: FieldLocalizationResource = defaultFamilyNameLocalization,
        focusState: FocusState<AccountInputFields?> = FocusState<AccountInputFields?>()
    ) {
        self._name = name
        self.givenNameLocalization = givenName
        self.familyNameLocalization = familyName
        self._focusedField = focusState
    }
}


#if DEBUG
struct NameTextFields_Previews: PreviewProvider {
    @State private static var name = PersonNameComponents()
    
    
    static var previews: some View {
        VStack {
            Form {
                NameTextFields(name: $name)
            }
                .frame(height: 300)
            NameTextFields(name: $name)
                .padding(32)
        }
            .background(Color(.systemGroupedBackground))
    }
}
#endif
