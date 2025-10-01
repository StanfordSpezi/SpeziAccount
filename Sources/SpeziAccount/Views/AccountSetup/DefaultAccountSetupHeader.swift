//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A view which provides the default title and subtitle text.
///
/// This view expects a ``Account`` object to be in the environment to dynamically
/// present the appropriate subtitle.
public struct DefaultAccountSetupHeader: View {
    @Environment(Account.self)
    private var account
    @Environment(\.accountSetupState)
    private var setupState

    public var body: some View {
        VStack(alignment: ProcessInfo.isIOSAtLeast26 ? .leading : .center) {
            Text("ACCOUNT_WELCOME", bundle: .module)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(ProcessInfo.isIOSAtLeast26 ? .leading : .center)
                .padding(.bottom)
                .padding(.top, 30)

            Group {
                if account.signedIn, case .presentingExistingAccount = setupState {
                    Text("ACCOUNT_WELCOME_SIGNED_IN_SUBTITLE", bundle: .module)
                } else {
                    Text("ACCOUNT_WELCOME_SUBTITLE", bundle: .module)
                }
            }
            .multilineTextAlignment(ProcessInfo.isIOSAtLeast26 ? .leading : .center)
        }
    }

    /// Initialize a new account header.
    public init() {}
}


#if DEBUG
#Preview {
    DefaultAccountSetupHeader()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    DefaultAccountSetupHeader()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock(userId: "myUser", name: nil))
        }
}
#endif
