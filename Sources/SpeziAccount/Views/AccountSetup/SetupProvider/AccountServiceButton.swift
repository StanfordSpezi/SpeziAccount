//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct AccountServiceButton<Label: View>: View {
    private let action: () -> Void
    private let label: Label

    public var body: some View {
        Button(action: action) {
            HStack {
                label
            }
                .font(.title3)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
        }
            .buttonStyle(.borderedProminent)
    }

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String = "person.crop.square",
        action: @escaping () -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(action: action) {
            SwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        action: @escaping () -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(action: action) {
            SwiftUI.Label(titleKey, image: image)
        }
    }

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
}


#if DEBUG
#Preview {
    AccountServiceButton("E-Mail and Password") {
        print("Pressed")
    }
}
#endif
