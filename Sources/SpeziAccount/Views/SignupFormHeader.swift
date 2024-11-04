//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct FormHeader<Image: View, Title: View, Instructions: View>: View {
    private let image: Image
    private let title: Title
    private let instructions: Instructions


    var body: some View {
        VStack {
            VStack {
                image
                    .foregroundColor(.accentColor)
                    .symbolRenderingMode(.multicolor)
                    .font(.custom("XXL", size: 50, relativeTo: .title))
                    .accessibilityHidden(true)
                title
                    .accessibilityAddTraits(.isHeader)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 4)
            }
                .accessibilityElement(children: .combine)
            instructions
                .padding([.leading, .trailing], 25)
        }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    init(@ViewBuilder image: () -> Image, @ViewBuilder title: () -> Title, @ViewBuilder instructions: () -> Instructions) {
        self.image = image()
        self.title = title()
        self.instructions = instructions()
    }
}


public struct SignupFormHeader: View {
    public var body: some View {
        FormHeader {
            Image(systemName: "person.fill.badge.plus") // swiftlint:disable:this accessibility_label_for_image
        } title: {
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
