//
// Created by Andreas Bauer on 27.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

// TODO move that to SpeziViews?
public struct AsyncDataEntrySubmitButton: View {
    private var title: LocalizedStringResource
    private var action: () async throws -> Void

    @Environment(\.defaultErrorDescription) var defaultErrorDescription
    @Binding private var state: ViewState

    public var body: some View {
        Button(action: submitAction) {
            Text(title)
                .padding(6)
                .frame(maxWidth: .infinity)
                .replaceWithProcessingIndicator(ifProcessing: state)
        }
        .buttonStyle(.borderedProminent)
        .disabled(state == .processing)
        .padding()
    }

    public init(
        _ title: LocalizedStringResource,
        state: Binding<ViewState>,
        action: @escaping () async throws -> Void
    ) {
        self.title = title
        self._state = state
        self.action = action
    }

    private func submitAction() {
        guard state != .processing else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            // TODO focusField = none?
            state = .processing
        }

        // TODO save the task handle?
        Task {
            do {
                try await action()
                withAnimation(.easeIn(duration: 0.2)) {
                    state = .idle
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
        var action: () async throws -> Void

        @State var state: ViewState

        var body: some View {
            AsyncDataEntrySubmitButton(title, state: $state) {
                print("Button pressed!")
                try await Task.sleep(for: .seconds(1))
                try await action()
            }
            .viewStateAlert(state: $state)
        }

        init(_ title: LocalizedStringResource = "Test Button", state: ViewState = .idle, action: @escaping () async throws -> Void = {}) {
            self.title = title
            self.action = action

            self._state = State(initialValue: state)
        }
    }

    static var previews: some View {
        PreviewView()
        PreviewView(state: .processing)
        PreviewView("Test Button with Error") {
            throw CancellationError()
        }
    }
}
#endif
