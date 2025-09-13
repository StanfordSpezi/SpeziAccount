//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziPersonalInfo
import SwiftUI


/// A account summary view that can be used to link to the `AccountOverview`.
///
/// Below is a short code example on how to use the `AccountHeader` view.
///
/// ```swift
/// struct MyView: View {
///     @Environment(Account.self)
///     private var account
///
///     var body: some View {
///         NavigationStack {
///             Form {
///                 if let details = account.details {
///                     Section {
///                         NavigationLink {
///                             AccountOverview()
///                         } label: {
///                             AccountHeader(details: details)
///                         }
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
    }
    
    @Environment(Account.self)
    private var account
    private let caption: Text

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
#if os(macOS)
                    .foregroundColor(Color(nsColor: .systemGray))
#elseif os(tvOS)
                    .foregroundColor(Color(.systemGray))
#elseif os(watchOS)
                    .foregroundColor(Color(.gray))
#else
                    .foregroundColor(Color(uiColor: .systemGray3))
#endif
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading) {
                let nameTitle = accountDetails?.name?.formatted(.name(style: .long)) ?? accountDetails?.userId ?? "Placeholder"

                Text(nameTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .redacted(reason: account.details == nil ? .placeholder : [])
                caption
                    .font(.caption)
            }
        }
    }
    
    /// Display a new Account Header.
    /// - Parameter caption: A descriptive text displayed under the account name giving the user a brief explanation of what to expect when they interact with the header.
    public init(caption: LocalizedStringResource = Defaults.caption) {
        self.init(caption: Text(caption))
    }

    /// Display a new Account Header.
    /// - Parameter caption: A descriptive text displayed under the account name giving the user a brief explanation of what to expect when they interact with the header.
    public init(caption: Text) {
        self.caption = caption
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return AccountHeader()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview {
    AccountHeader(caption: Text(verbatim: "Email, Password, Preferences"))
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#if !os(macOS) && !os(watchOS)
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

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
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"

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
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
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
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
#endif
