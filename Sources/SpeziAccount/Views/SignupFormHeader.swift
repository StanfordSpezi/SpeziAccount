//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


public struct SignupFormHeader: View {
    public var body: some View {
        ListHeader(systemImage: "person.fill.badge.plus") {
            Text("UP_SIGNUP_HEADER", bundle: .module)
        } instructions: {
            Text("UP_SIGNUP_INSTRUCTIONS", bundle: .module)
        }
    }

    public init() {}
}


#if DEBUG
#Preview {
    SignupFormHeader()
}
#endif
