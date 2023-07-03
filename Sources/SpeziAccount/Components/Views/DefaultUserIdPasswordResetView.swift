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

public struct DefaultUserIdPasswordResetView<Service: UserIdPasswordAccountService, SuccessView: View>: View {
    private let service: Service
    private let successViewBuilder: () -> SuccessView

    @State private var userId = ""
    @State private var requestSubmitted = false

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: AccountInputFields?
    @StateObject private var validationEngine = ValidationEngine(rules: .nonEmpty)

    public var body: some View {
        VStack {
            if requestSubmitted {
                successViewBuilder()
            } else {
                VStack {
                    // TODO maybe center this thing in the scroll view (e.g. iPad view?)

                    VerifiableTextField(service.configuration.userIdType.localizedStringResource, text: $userId)
                        .environmentObject(validationEngine)
                        .textFieldStyle(.roundedBorder)
                        .disableFieldAssistants()
                        .fieldConfiguration(service.configuration.userIdField)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .userId)
                        .font(.title3)


                    AsyncDataEntrySubmitButton(state: $state, action: submitRequestAction) {
                        Text("Reset Password")
                            .padding(8)
                            .frame(maxWidth: .infinity)
                    }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 20)
                        .padding()
                }
                    .padding()
                    .environment(\.defaultErrorDescription, .init("UAP_RESET_PASSWORD_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))

                Spacer()
            }
        }
            .navigationTitle("UP_RESET_PASSWORD".localized(.module).localizedString())
            .disableAnyDismissiveActions(ifProcessing: state)
            .viewStateAlert(state: $state)
            .onTapGesture {
                focusedField = nil
            }
            .embedIntoScrollViewScaledToFit()
    }

    public init(using service: Service, @ViewBuilder success successViewBuilder: @escaping () -> SuccessView) {
        self.service = service
        self.successViewBuilder = successViewBuilder
    }

    private func submitRequestAction() async throws {
        validationEngine.runValidation(input: userId)
        guard validationEngine.inputValid else {
            focusedField = .userId
            return
        }

        focusedField = nil

        try await service.resetPassword(userId: userId)

        withAnimation(.easeOut(duration: 0.5)) {
            requestSubmitted = true
        }

        try await Task.sleep(for: .milliseconds(515))
        state = .idle
    }
}

#if DEBUG
struct DefaultUserIdPasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultUserIdPasswordResetView(using: DefaultUsernamePasswordAccountService()) {
                DefaultSuccessfulPasswordResetView()
            }
        }
    }
}
#endif
