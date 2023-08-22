//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountServiceButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
        }
            .foregroundColor(.accentColor)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .padding(1)
            )
            .cornerRadius(8)
    }
}


extension View {
    /// Draw the standard background of a ``AccountService`` button (see ``AccountSetupViewStyle/makeServiceButtonLabel()-6ihdh``.
    public func accountServiceButtonBackground() -> some View {
        modifier(AccountServiceButtonModifier())
    }
}


#if DEBUG
struct UsernamePasswordLoginServiceButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Image(systemName: "ellipsis.rectangle")
                .font(.title2)
            Text("USER_ID_EMAIL", bundle: .module)
        }
            .accountServiceButtonBackground()
    }
}
#endif
