//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// TODO: rename file and move!

// TODO: just remove?

public struct AccountServiceButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.accentColor)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .padding(1)
                    .opacity(configuration.isPressed ? 0.5 : 1.0)
            )
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
        // TODO: rethink that design though!
    }
}


extension ButtonStyle where Self == AccountServiceButtonStyle {
    public static var accountServiceButton: Self {
        AccountServiceButtonStyle()
    }
}


struct AccountServiceButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack { // TODO: button style!
            content
        }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .padding(1)
            )
            .background(Color.accentColor)
            .cornerRadius(8)
    }
}


extension View {
    /// Draw the standard background of a ``AccountService`` button (see ``AccountSetupViewStyle/makeServiceButtonLabel(_:)-54dx4``.
    public func accountServiceButtonBackground() -> some View { // TODO: eventually remove!
        modifier(AccountServiceButtonModifier())
    }
}


#if DEBUG
#Preview {
    Button {
        print("pressed")
    } label: {
        Group {
            Image(systemName: "person.crop.square")
                .font(.title2)
                .accessibilityHidden(true)
            Text("USER_ID_EMAIL", bundle: .module)
        }
            .accountServiceButtonBackground()
    }
    Button {
        print("pressed")
    } label: {
        HStack {
            Image(systemName: "person.crop.square")
                .font(.title2)
                .accessibilityHidden(true)
            Text("USER_ID_EMAIL", bundle: .module)
        }
    }
        .buttonStyle(.accountServiceButton)

    Button {
        print("Pressed")
    } label: {
        HStack {
            Image(systemName: "person.crop.square")
                .font(.title2)
                .accessibilityHidden(true)
            Text("USER_ID_EMAIL", bundle: .module)
        }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
    }
        .buttonStyle(.borderedProminent)
}
#endif
