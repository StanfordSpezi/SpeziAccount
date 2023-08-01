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


private enum PasswordResetFocusState {
    case userId
}


public struct UserIdPasswordResetView<Service: UserIdPasswordAccountService, SuccessView: View>: View {
    private let service: Service
    private let successViewBuilder: () -> SuccessView

    private var userIdConfiguration: UserIdConfiguration {
        service.configuration.userIdConfiguration
    }

    @State private var userId = ""
    @State private var requestSubmitted = false

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: PasswordResetFocusState?
    @StateObject private var validationEngine = ValidationEngine(rules: .nonEmpty) // TODO use signup validation?

    public var body: some View {
        VStack {
            if requestSubmitted {
                successViewBuilder()
            } else {
                VStack {
                    // TODO maybe center this thing in the scroll view (e.g. iPad view?)

                    VerifiableTextField(userIdConfiguration.idType.localizedStringResource, text: $userId)
                        .environmentObject(validationEngine)
                        .textFieldStyle(.roundedBorder)
                        .disableFieldAssistants()
                        .fieldConfiguration(userIdConfiguration.fieldType)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .userId)
                        .font(.title3)


                    AsyncButton(state: $state, action: submitRequestAction) {
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
            .disableDismissiveActions(isProcessing: state)
            .viewStateAlert(state: $state)
            .embedIntoScrollViewScaledToFit()
            .onTapGesture {
                focusedField = nil
            }
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
    static let accountService = MockUsernamePasswordAccountService()
    static var previews: some View {
        NavigationStack {
            UserIdPasswordResetView(using: accountService) {
                SuccessfulPasswordResetView()
            }
                .environmentObject(Account(accountService))
        }
    }
}
#endif
