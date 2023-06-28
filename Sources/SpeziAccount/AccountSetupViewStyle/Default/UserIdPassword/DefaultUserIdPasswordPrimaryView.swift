//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DefaultUserIdPasswordPrimaryView<Service: UserIdPasswordAccountService>: View {
    private let service: Service

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    header

                    Spacer()

                    VStack {
                        DefaultUserIdPasswordEmbeddedView(using: service) // TODO pass all the other things
                    }
                        .padding(.horizontal, AccountSetup.Constants.innerHorizontalPadding)

                    Spacer()
                    Spacer()
                    Spacer()
                }
                    .padding(.horizontal, AccountSetup.Constants.outerHorizontalPadding)
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// The Views Title and subtitle text.
    @ViewBuilder
    var header: some View {
        // TODO provide customizable with AccountViewStyle!
        Text("Welcome back!") // TODO localize
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .padding(.top, 30)

        Text("Please create an account to do whatever. You may create an account if you don't have one already!") // TODO localize!
            .multilineTextAlignment(.center)
    }

    init(using service: Service) {
        self.service = service
    }
}

struct DefaultUserIdPasswordPrimaryView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultUserIdPasswordPrimaryView(using: DefaultUsernamePasswordAccountService())
    }
}