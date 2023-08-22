//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct IdentityProviderSection: View {
    private let providers: [any IdentityProvider]

    var body: some View {
        VStack {
            ForEach(providers.indices, id: \.self) { index in
                providers[index].makeAnySignInButton()
            }
        }
    }

    init(providers: [any IdentityProvider]) {
        self.providers = providers
    }
}


extension IdentityProvider {
    func makeAnySignInButton() -> AnyView {
        AnyView(self.makeSignInButton())
    }
}


#if DEBUG
struct IdentityProviderSection_Previews: PreviewProvider {
    static var previews: some View {
        IdentityProviderSection(providers: [MockSignInWithAppleProvider()])
    }
}
#endif
