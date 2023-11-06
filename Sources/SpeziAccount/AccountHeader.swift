//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI


/// A account summary view that can be used to link to the ``AccountOverview``.
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
    /// Default values for the ``AccountHeader`` view.
    @_documentation(visibility: internal)
    public enum Defaults {
        /// Default caption.
        @_documentation(visibility: internal)
        public static let caption = LocalizedStringResource("ACCOUNT_HEADER_CAPTION", bundle: .atURL(from: .module))
        // swiftlint:disable:previous attributes
    }
    
    @EnvironmentObject private var account: Account
    private var caption: LocalizedStringResource
    
    public var body: some View {
        let accountDetails = account.details
        
        HStack {
            if let accountDetails,
               let name = accountDetails.name {
                UserProfileView(name: name)
                    .frame(height: 60)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color(.systemGray3))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading) {
                let nameTitle = accountDetails?.name?.formatted(.name(style: .long)) ?? accountDetails?.userId ?? "Placeholder"

                Text(nameTitle)
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
    public init(caption: LocalizedStringResource = Defaults.caption) {
        self.caption = caption
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

#Preview {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")

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

#Preview {
    NavigationStack {
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
        .environmentObject(Account(MockUserIdPasswordAccountService()))
}
#endif
