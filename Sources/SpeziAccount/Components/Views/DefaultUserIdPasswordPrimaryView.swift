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
                    welcomeHeader

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
    }

    /// The Views Title and subtitle text.
    @ViewBuilder
    var welcomeHeader: some View {
        // TODO provide customizable with AccountViewStyle!
        Text("ACCOUNT_WELCOME".localized(.module))
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .padding(.top, 30)

        Text("ACCOUNT_WELCOME_SUBTITLE".localized(.module))
            .multilineTextAlignment(.center)
    }

    init(using service: Service) {
        self.service = service
    }
}

struct DefaultUserIdPasswordPrimaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultUserIdPasswordPrimaryView(using: DefaultUsernamePasswordAccountService())
        }
    }
}
