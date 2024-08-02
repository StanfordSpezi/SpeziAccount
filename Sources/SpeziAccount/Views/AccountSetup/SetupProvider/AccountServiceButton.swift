//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


public struct AccountServiceButton<Label: View>: View {
    private let action: () async throws -> Void
    private let label: Label

    @Binding private var state: ViewState

    public var body: some View {
        AsyncButton(state: $state, action: action) {
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
        action: @escaping () async -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(titleKey, systemImage: systemImage, state: .constant(.idle), action: action)
    }

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String = "person.crop.square",
        state: Binding<ViewState>,
        action: @escaping () async -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(action: action, state: state) {
            SwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        action: @escaping () async -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(titleKey, image: image, state: .constant(.idle), action: action)
    }

    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        state: Binding<ViewState>,
        action: @escaping () async -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(action: action, state: state) {
            SwiftUI.Label(titleKey, image: image)
        }
    }

    public init(
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: action, state: .constant(.idle), label: label)
    }

    public init(
        action: @escaping () async throws -> Void,
        state: Binding<ViewState>,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self._state = state
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
