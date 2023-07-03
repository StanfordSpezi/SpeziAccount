//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziViews
import SwiftUI

// TODO move that to SpeziViews?
public struct AsyncDataEntrySubmitButton<ButtonLabel: View>: View {
    private var buttonLabel: ButtonLabel
    private var role: ButtonRole?
    private var action: () async throws -> Void

    @Environment(\.defaultErrorDescription)
    var defaultErrorDescription

    @Binding private var state: ViewState

    public var body: some View {
        Button(role: role, action: submitAction) {
            buttonLabel
                .replaceWithProcessingIndicator(ifProcessing: state)
        }
        .disabled(state == .processing)
    }

    public init(
        _ title: LocalizedStringResource,
        role: ButtonRole? = nil,
        state: Binding<ViewState>,
        action: @escaping () async throws -> Void
    ) where ButtonLabel == Text {
        self.init(role: role, state: state, action: action) {
            Text(title)
        }
    }

    public init(
        role: ButtonRole? = nil,
        state: Binding<ViewState>,
        action: @escaping () async throws -> Void,
        @ViewBuilder _ label: () -> ButtonLabel
    ) {
        self.buttonLabel = label()
        self.role = role
        self._state = state
        self.action = action
    }

    private func submitAction() {
        guard state != .processing else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            state = .processing
        }

        // TODO save the task handle?
        Task {
            do {
                try await action()

                // the button action might set the state back to idle to prevent this animation
                if state != .idle {
                    withAnimation(.easeIn(duration: 0.2)) {
                        state = .idle
                    }
                }
            } catch {
                state = .error(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: defaultErrorDescription
                ))
            }
        }
    }
}

#if DEBUG
struct AsyncDataEntrySubmitButton_Previews: PreviewProvider {
    struct PreviewView: View {
        var title: LocalizedStringResource
        var role: ButtonRole?
        var action: () async throws -> Void

        @State var state: ViewState

        var body: some View {
            AsyncDataEntrySubmitButton(title, role: role, state: $state) {
                try await Task.sleep(for: .seconds(1))
                try await action()
            }
            .viewStateAlert(state: $state)
        }

        init(
            _ title: LocalizedStringResource = "Test Button",
            role: ButtonRole? = nil,
            state: ViewState = .idle,
            action: @escaping () async throws -> Void = {}
        ) {
            self.title = title
            self.role = role
            self.action = action

            self._state = State(initialValue: state)
        }
    }

    @State static var state: ViewState = .idle // won't update the preview

    static var previews: some View {
        PreviewView()
        PreviewView(state: .processing)
        PreviewView("Test Button with Error") {
            throw CancellationError()
        }

        PreviewView("Destructive Button", role: .destructive)
            .buttonStyle(.automatic)

        AsyncDataEntrySubmitButton(state: $state, action: { print("button pressed") }) {
            Text("Test Button!")
        }
    }
}
#endif
