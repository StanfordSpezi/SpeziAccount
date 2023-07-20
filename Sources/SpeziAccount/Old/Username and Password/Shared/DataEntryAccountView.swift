//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct DataEntryAccountView: View {
    private let content: AnyView
    private let buttonTitle: String
    private let buttonPressed: () async throws -> Void
    private let footer: AnyView
    private let defaultError: String // TODO update to the modifier!
    
    @Binding private var valid: Bool
    @FocusState private var focusedField: AccountInputFields?
    @State private var state: ViewState = .idle
    
    
    var body: some View {
        ScrollView {
            content
            resetPasswordButton
            footer
        }
            .navigationBarBackButtonHidden(state == .processing)
            .onTapGesture {
                focusedField = nil
            }
            .viewStateAlert(state: $state)
    }

    @MainActor
    private var resetPasswordButton: some View {
        let localized = LocalizedStringResource(stringLiteral: buttonTitle)

        // TODO AsyncButton impsoes MainActor requirement!
        return AsyncButton(state: $state, action: buttonPressed) {
            Text(localized)
                .padding(6)
                .frame(maxWidth: .infinity)
        }
            .disabled(!valid)
            .environment(\.defaultErrorDescription, LocalizedStringResource(stringLiteral: defaultError))
            .padding()
    }
    
    
    init<Content: View, Footer: View>(
        buttonTitle: String,
        defaultError: String,
        focusState: FocusState<AccountInputFields?> = FocusState<AccountInputFields?>(),
        valid: Binding<Bool> = .constant(true),
        buttonPressed: @escaping () async throws -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer = { EmptyView() }
    ) {
        self.buttonTitle = buttonTitle
        self._focusedField = focusState
        self._valid = valid
        self.buttonPressed = buttonPressed
        self.defaultError = defaultError
        self.content = AnyView(content())
        self.footer = AnyView(footer())
    }
}


#if DEBUG
struct DataEntryView_Previews: PreviewProvider {
    static var previews: some View {
        buildPreview("Test") {
            try await Task.sleep(for: .seconds(2))
            print("Pressed!")
        }

        buildPreview("Test with Error") {
            throw CancellationError()
        }
    }

    static func buildPreview(_ title: String, buttonPressed: @escaping () async throws -> Void) -> some View {
        NavigationStack {
            DataEntryAccountView(
                buttonTitle: title,
                defaultError: "Default Error",
                buttonPressed: buttonPressed
            ) {
                Text("Content ...")
            }
        }
    }
}
#endif
