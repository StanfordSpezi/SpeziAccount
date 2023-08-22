//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Simple `Divider` that reads "or" in the middle to divide sections that provide non-overlapping options of choice to the user.
struct ServicesDivider: View {
    var body: some View {
        HStack {
            VStack {
                Divider()
            }
            Text("OR", bundle: .module)
                .padding(.horizontal, 8)
                .font(.subheadline)
                .foregroundColor(.secondary)
            VStack {
                Divider()
            }
        }
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
    }

    init() {}
}


#if DEBUG
struct ServicesDivider_Previews: PreviewProvider {
    static var previews: some View {
        ServicesDivider()
    }
}
#endif
