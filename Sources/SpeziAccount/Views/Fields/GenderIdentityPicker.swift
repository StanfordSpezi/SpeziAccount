//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A simple `Picker` implementation for ``GenderIdentity`` entry.
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
            }
        )
    }

    /// Initialize a new `GenderIdentityPicker`.
    /// - Parameters:
    ///   - genderIdentity: A binding to the ``GenderIdentity`` state.
    ///   - customTitle: Optionally provide a custom label text.
    public init(
        genderIdentity: Binding<GenderIdentity>,
        title customTitle: LocalizedStringResource? = nil
    ) {
        self._genderIdentity = genderIdentity
        self.titleLocalization = customTitle ?? GenderIdentityKey.name
    }
}


#if DEBUG
struct GenderIdentityPicker_Previews: PreviewProvider {
    @State private static var genderIdentity: GenderIdentity = .male
    
    
    static var previews: some View {
        Form {
            Grid {
                GenderIdentityPicker(genderIdentity: $genderIdentity)
            }
        }

        Grid {
            GenderIdentityPicker(genderIdentity: $genderIdentity)
        }
            .padding(32)
            .background(Color(.systemGroupedBackground))
    }
}
#endif
