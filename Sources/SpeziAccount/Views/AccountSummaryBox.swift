//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI


/// A simple account summary displayed in the `AccountSetup` view when there is already a signed in user account.
struct AccountSummaryBox: View {
    private let model: AccountDisplayModel

    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let profileViewName = model.profileViewName {
                    UserProfileView(name: profileViewName)
                        .frame(height: 40)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
#if os(macOS)
                        .foregroundColor(Color(.systemGray))
#else
                        .foregroundColor(Color(uiColor: .systemGray3))
#endif
                        .accessibilityHidden(true)
                }
            }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                if let accountHeadline = model.accountHeadline {
                    Text(accountHeadline)
                } else {
                    Text("Anonymous User", bundle: .module)
                }
                if let subheadline = model.accountSubheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.background)
                    .shadow(color: .gray, radius: 2)
            )
            .frame(maxWidth: ViewSizing.maxFrameWidth)
            .accessibilityElement(children: .combine)
    }

    /// Create a new `AccountSummaryBox`
    /// - Parameter details: The ``AccountDetails`` to render.
    init(details: AccountDetails) {
        self.model = AccountDisplayModel(details: details)
    }
}


#if DEBUG
#Preview {
    AccountSummaryBox(details: .createMock())
        .padding(.horizontal, ViewSizing.innerHorizontalPadding)
}

#Preview {
    AccountSummaryBox(details: .createMock(userId: "leland.stanford"))
        .padding(.horizontal, ViewSizing.innerHorizontalPadding)
}

#Preview {
    AccountSummaryBox(details: .createMock(userId: "leland.stanford", name: nil))
        .padding(.horizontal, ViewSizing.innerHorizontalPadding)
}

#Preview {
    AccountSummaryBox(details: .createMock(name: nil))
        .padding(.horizontal, ViewSizing.innerHorizontalPadding)
}
#endif
