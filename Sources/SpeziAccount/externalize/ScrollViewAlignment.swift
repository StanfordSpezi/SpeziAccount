//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension View {
    public func embedIntoScrollViewScaledToFit() -> some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    self
                }
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
    }
}

/*
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    header
                        .padding(.bottom, 32)

                    form
                }
                .padding(.horizontal, AccountSetup.Constants.outerHorizontalPadding)
                .frame(minHeight: proxy.size.height)
                .frame(maxWidth: .infinity)
            }
        }
        */
