//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension View {
    public func embedIntoScrollViewScaledToFit() -> some View { // TODO remove
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
