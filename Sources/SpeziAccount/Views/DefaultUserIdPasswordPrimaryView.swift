//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

struct DefaultUserIdPasswordPrimaryView<Service: UserIdPasswordAccountService>: View {
    private let service: Service

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    // TODO this header shouldn't require an injected Account object!
                    AccountSetupDefaultHeader() // TODO provide ability to replace it!

                    Spacer()

                    VStack {
                        DefaultUserIdPasswordEmbeddedView(using: service)
                    }
                        .padding(.horizontal, Constants.innerHorizontalPadding)
                        .frame(maxWidth: Constants.maxFrameWidth)

                    Spacer()
                    Spacer()
                    Spacer()
                }
                    .padding(.horizontal, Constants.outerHorizontalPadding)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
        // TODO navigation title?
    }

    init(using service: Service) {
        self.service = service
    }
}

#if DEBUG
struct DefaultUserIdPasswordPrimaryView_Previews: PreviewProvider {
    static let accountService = MockUsernamePasswordAccountService()
    static var previews: some View {
        NavigationStack {
            DefaultUserIdPasswordPrimaryView(using: accountService)
                .environmentObject(Account(accountService))
        }
    }
}
#endif
