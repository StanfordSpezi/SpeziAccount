//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountServiceButtonList: View {
    private let services: [any AccountService]

    var body: some View {
        // We use indices here as the preview provider has some issues with ForEach and a `any` existential.
        // As the array doesn't change this is completely fine and the index is a stable identifier.
        ForEach(services.indices, id: \.self) { index in
            let service = services[index]
            let style = service.viewStyle

            NavigationLink {
                AnyView(style.makePrimaryView(service))
            } label: {
                style.makeAnyAccountServiceButtonLabel(service)
            }
        }
    }

    init(services: [any AccountService]) {
        self.services = services
    }
}


extension AccountSetupViewStyle {
    fileprivate func makeAnyAccountServiceButtonLabel(_ service: any AccountService) -> AnyView {
        // as the `AccountSetup` only has a type-erased view on the `AccountSetupViewStyle`
        // we can't, because of the default implementation, create the AnyView inline.
        AnyView(self.makeServiceButtonLabel(service))
    }
}


#if DEBUG
struct AccountServiceButtonList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AccountServiceButtonList(services: [
                MockUserIdPasswordAccountService(),
                MockSimpleAccountService()
            ])
        }
    }
}
#endif
