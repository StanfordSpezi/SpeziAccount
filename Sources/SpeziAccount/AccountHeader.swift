//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

/// A summary view for ``SpeziAccountOverview`` that can be used as a Button to link to ``SpeziAccountOverview``.
///
/// Below is a short code example on how to use the `AccountHeader` view.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         NavigationStack {
///             Form {
///                 Section {
///                     NavigationLink {
///                         AccountOverview()
///                     } label: {
///                         AccountHeader(details: details)
///                     }
///                 }
///             }
///         }
///     }
/// }
/// ```


public struct AccountHeader: View {
    private let model: AccountDisplayModel
    
    public var body: some View {
        HStack {
            Group {
                if let profileViewName = model.profileViewName {
                    UserProfileView(name: profileViewName)
                        .frame(height: 60)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color(.systemGray))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(model.accountHeadline)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Email, Password, Preferences").font(.caption)
            }
        }
    }
    
    public init(details: AccountDetails) {
        self.model = AccountDisplayModel(details: details)
    }
}


#if DEBUG
#Preview {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build(owner: MockUserIdPasswordAccountService())
    
    return AccountHeader(details: details)
}

#Preview {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build(owner: MockUserIdPasswordAccountService())
    
    return NavigationStack {
        Form {
            Section {
                NavigationLink {
                    AccountOverview()
                } label: {
                    AccountHeader(details: details)
                }
            }
        }
    }.environmentObject(Account(MockUserIdPasswordAccountService()))
}
#endif
