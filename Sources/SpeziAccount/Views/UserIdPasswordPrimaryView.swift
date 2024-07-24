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
public struct UserIdPasswordPrimaryView: View { // TODO: probably remove that one here?
    public var body: some View { // TODO: is that the base for the AccountSetup view?
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    DefaultAccountSetupHeader()

                    Spacer()

                    VStack {
                        // TODO: UserIdPasswordEmbeddedView(using: service)
                        EmptyView()
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


    init() {}
}


#if DEBUG
#Preview {
    NavigationStack {
        UserIdPasswordPrimaryView()
            .previewWith {
                AccountConfiguration(service: MockAccountService())
            }
    }
}
#endif
