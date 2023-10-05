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
    @EnvironmentObject private var account: Account
    private var caption: LocalizedStringResource
    
    public var body: some View {
        let accountDetails = account.details
        
        HStack {
            UserProfileView(name: accountDetails?.name ?? PersonNameComponents(givenName: "Placeholder", familyName: "Placeholder"))
                .frame(height: 60)
                .redacted(reason: account.details == nil ? .placeholder : [])
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(accountDetails?.name?.formatted() ?? "Placeholder")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .redacted(reason: account.details == nil ? .placeholder : [])
                Text(caption)
                    .font(.caption)
            }
        }
    }
    
    /// Display a new Account Header.
    /// - Parameter caption: A descriptive text displayed under the account name giving the user a brief explanation of what to expect when they interact with the header.
    public init(caption: LocalizedStringResource? = nil) {
        self.caption = caption ?? LocalizedStringResource("ACCOUNT_HEADER_CAPTION", bundle: .atURL(from: .module))
    }
}


#if DEBUG
#Preview {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
    
    return AccountHeader()
        .environmentObject(Account(building: details, active: MockUserIdPasswordAccountService()))
}

#Preview {
    AccountHeader(caption: "Email, Password, Preferences")
        .environmentObject(Account(MockUserIdPasswordAccountService()))
}

#Preview {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
    
    return NavigationStack {
        Form {
            Section {
                NavigationLink {
                    AccountOverview()
                } label: {
                    AccountHeader()
                }
            }
        }
    }
        .environmentObject(Account(building: details, active: MockUserIdPasswordAccountService()))
}
#endif
