//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI


struct AccountOverviewHeader: View {
    private let model: AccountDisplayModel

    
    var body: some View {
        VStack {
            Group {
                if let profileViewName = model.profileViewName {
                    UserProfileView(name: profileViewName)
                        .frame(height: 90)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                    #if os(macOS) || os(tvOS)
                        .foregroundColor(Color(.systemGray))
                    #elseif !os(watchOS)
                        .foregroundColor(Color(.systemGray3))
                    #endif
                        .accessibilityHidden(true)
                }
            }
                .accessibilityHidden(true)

            if let accountHeadline = model.accountHeadline {
                Text(accountHeadline)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            if let accountSubheadline = model.accountSubheadline {
                Text(accountSubheadline)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
            .accessibilityElement(children: .combine)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }


    init(details: AccountDetails) {
        self.model = AccountDisplayModel(details: details)
    }
}


#if DEBUG
#Preview {
    AccountOverviewHeader(details: .createMock())
}
#endif
