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
    private let action: @MainActor () async throws -> Void
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
        _ titleKey: LocalizedStringResource,
        systemImage: String = "person.crop.square",
        action: @escaping @MainActor  () async -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(titleKey, systemImage: systemImage, state: .constant(.idle), action: action)
    }

    public init(
        _ titleKey: LocalizedStringResource,
        systemImage: String = "person.crop.square", // swiftlint:disable:this function_default_parameter_at_end
        state: Binding<ViewState>,
        action: @escaping @MainActor  () async throws -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(state: state, action: action) {
            SwiftUI.Label {
                Text(titleKey)
            } icon: {
                Image(systemName: systemImage) // swiftlint:disable:this accessibility_label_for_image
            }
        }
    }

    public init(
        _ titleKey: LocalizedStringResource,
        image: ImageResource,
        action: @escaping @MainActor () async -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(titleKey, image: image, state: .constant(.idle), action: action)
    }

    public init(
        _ titleKey: LocalizedStringResource,
        image: ImageResource,
        state: Binding<ViewState>,
        action: @escaping @MainActor () async throws -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(state: state, action: action) {
            SwiftUI.Label {
                Text(titleKey)
            } icon: {
                Image(image) // swiftlint:disable:this accessibility_label_for_image
            }
        }
    }

    public init(
        action: @escaping @MainActor () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.init(state: .constant(.idle), action: action, label: label)
    }

    public init(
        state: Binding<ViewState>,
        action: @escaping @MainActor () async throws -> Void,
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
