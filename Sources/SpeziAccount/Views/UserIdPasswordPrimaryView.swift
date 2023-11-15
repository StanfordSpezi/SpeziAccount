//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A primary view implementation for a ``UserIdPasswordAccountService``.
public struct UserIdPasswordPrimaryView: View {
    private let service: any UserIdPasswordAccountService


    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    DefaultAccountSetupHeader()

                    Spacer()

                    VStack {
                        UserIdPasswordEmbeddedView(using: service)
                    }
                        .padding(.horizontal, ViewSizing.innerHorizontalPadding)
                        .frame(maxWidth: ViewSizing.maxFrameWidth)

                    Spacer()
                    Spacer()
                    Spacer()
                }
                    .padding(.horizontal, ViewSizing.outerHorizontalPadding)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
    }


    init(using service: any UserIdPasswordAccountService) {
        self.service = service
    }
}


#if DEBUG
struct DefaultUserIdPasswordPrimaryView_Previews: PreviewProvider {
    static let accountService = MockUserIdPasswordAccountService()


    static var previews: some View {
        NavigationStack {
            UserIdPasswordPrimaryView(using: accountService)
                .environment(Account(accountService))
        }
    }
}
#endif
