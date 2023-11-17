//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountServicesSection: View {
    private let services: [any AccountService]

    private var embeddableAccountService: (any EmbeddableAccountService)? {
        let embeddableServices = services
            .filter { $0 is any EmbeddableAccountService }

        if embeddableServices.count == 1 {
            return embeddableServices.first as? any EmbeddableAccountService
        }

        return nil
    }

    private var nonEmbeddableAccountServices: [any AccountService] {
        services
            .filter { !($0 is any EmbeddableAccountService) }
    }

    var body: some View {
        if let embeddableService = embeddableAccountService {
            let embeddableViewStyle = embeddableService.viewStyle
            AnyView(embeddableViewStyle.makeEmbeddedAccountView(embeddableService))

            if !nonEmbeddableAccountServices.isEmpty {
                ServicesDivider()

                AccountServiceButtonList(services: nonEmbeddableAccountServices)
            } else {
                EmptyView()
            }
        } else {
            // there is no primary embeddable account service, list all as buttons
            AccountServiceButtonList(services: services)
        }
    }

    init(services: [any AccountService]) {
        self.services = services
    }
}


#if DEBUG
struct AccountServicesSection_Previews: PreviewProvider {
    static var accountServicePermutations: [[any AccountService]] = {
        [
            [MockUserIdPasswordAccountService()],
            [MockSimpleAccountService()],
            [MockUserIdPasswordAccountService(), MockSimpleAccountService()],
            [
                MockUserIdPasswordAccountService(),
                MockSimpleAccountService(),
                MockUserIdPasswordAccountService()
            ]
        ]
    }()

    static var previews: some View {
        ForEach(accountServicePermutations.indices, id: \.self) { index in
            NavigationStack {
                AccountServicesSection(services: accountServicePermutations[index])
            }
        }
    }
}
#endif
