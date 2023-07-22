//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct GenderIdentityPicker: View {
    private let titleLocalization: LocalizedStringResource

    @Binding private var genderIdentity: GenderIdentity
    
    public var body: some View {
        Picker(
            selection: $genderIdentity,
            content: {
                ForEach(GenderIdentity.allCases) { genderIdentity in
                    Text(String(localized: genderIdentity.localizedStringResource))
                        .tag(genderIdentity)
                }
            }, label: {
                Text(titleLocalization)
                    .fontWeight(.semibold)
            }
        )
    }

    public init(
        genderIdentity: Binding<GenderIdentity>,
        title customTitle: LocalizedStringResource? = nil
    ) {
        self._genderIdentity = genderIdentity
        self.titleLocalization = customTitle ?? LocalizedStringResource("GENDER_IDENTITY_TITLE", bundle: .atURL(from: .module))
    }
    
    public init(genderIdentity: Binding<GenderIdentity>, title: String.LocalizationValue) {
        self.init(genderIdentity: genderIdentity, title: LocalizedStringResource(title))
    }
}


#if DEBUG
struct GenderIdentityPicker_Previews: PreviewProvider {
    @State private static var genderIdentity: GenderIdentity = .male
    
    
    static var previews: some View {
        VStack {
            Form {
                Grid {
                    GenderIdentityPicker(genderIdentity: $genderIdentity)
                }
            }
                .frame(height: 200)
            Grid {
                GenderIdentityPicker(genderIdentity: $genderIdentity)
            }
                .padding(32)
        }
            .background(Color(.systemGroupedBackground))
    }
}
#endif
