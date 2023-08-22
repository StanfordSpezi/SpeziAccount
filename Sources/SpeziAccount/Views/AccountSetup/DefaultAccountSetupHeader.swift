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
    @EnvironmentObject private var account: Account

    public var body: some View {
        VStack {
            Text("ACCOUNT_WELCOME", bundle: .module)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .padding(.top, 30)

            Group {
                if !account.signedIn {
                    Text("ACCOUNT_WELCOME_SUBTITLE", bundle: .module)
                } else {
                    Text("ACCOUNT_WELCOME_SIGNED_IN_SUBTITLE", bundle: .module)
                }
            }
                .multilineTextAlignment(.center)
        }
    }

    /// Initialize a new account header.
    public init() {}
}


#if DEBUG
struct DefaultAccountSetupHeader_Previews: PreviewProvider {
    static var previews: some View {
        DefaultAccountSetupHeader()
            .environmentObject(Account())

        DefaultAccountSetupHeader()
            .environmentObject(Account(building: .init().set(\.userId, value: "myUser"), active: MockUserIdPasswordAccountService()))
    }
}
#endif
