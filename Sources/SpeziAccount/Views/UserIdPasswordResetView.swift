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


/// A password reset view implementation for a ``UserIdPasswordAccountService``.
public struct UserIdPasswordResetView<Service: UserIdPasswordAccountService, SuccessView: View>: View {
    private let service: Service
    private let successView: SuccessView

    private var userIdConfiguration: UserIdConfiguration {
        service.configuration.userIdConfiguration
    }

    @Environment(\.dismiss) private var dismiss

    @State private var userId = ""
    @State private var requestSubmitted: Bool

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: PasswordResetFocusState?
    @StateObject private var validationEngine = ValidationEngine(rules: .nonEmpty)


    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    if requestSubmitted {
                        successView
                    } else {
                        resetPasswordForm
                        Spacer()
                    }
                }
                    .navigationTitle(Text("UP_RESET_PASSWORD", bundle: .module))
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                    .disableDismissiveActions(isProcessing: state)
                    .viewStateAlert(state: $state)
                    .toolbar {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("DONE", bundle: .module)
                        }
                    }
                    .onTapGesture {
                        focusedField = nil
                    }
            }
        }
    }

    @ViewBuilder private var resetPasswordForm: some View {
        VStack {
            Text("UAP_PASSWORD_RESET_SUBTITLE \(userIdConfiguration.idType.localizedStringResource)", bundle: .module)
                .padding()
                .padding(.bottom, 30)

            VerifiableTextField(userIdConfiguration.idType.localizedStringResource, text: $userId)
                .environmentObject(validationEngine)
                .textFieldStyle(.roundedBorder)
                .disableFieldAssistants()
                .textContentType(userIdConfiguration.textContentType)
                .keyboardType(userIdConfiguration.keyboardType)
                .onTapFocus(focusedField: _focusedField, fieldIdentifier: .userId)
                .font(.title3)
        }
            .padding()
            .frame(maxWidth: MagicValue.maxFrameWidth * 1.5) // landscape optimizations
            .environment(\.defaultErrorDescription, .init("UAP_RESET_PASSWORD_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    VStack {
                        AsyncButton(state: $state, action: submitRequestAction) {
                            Text("Reset Password")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                        }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        Spacer()
                            .frame(height: 30)
                    }
                }
            }
    }

    fileprivate init(using service: Service, requestSubmitted: Bool, @ViewBuilder success successViewBuilder: () -> SuccessView) {
        self.service = service
        self.successView = successViewBuilder()
        self._requestSubmitted = State(wrappedValue: requestSubmitted)
    }


    /// Create a new view.
    /// - Parameters:
    ///   - service: The ``UserIdPasswordAccountService`` instance.
    ///   - successViewBuilder: A view to display on successful password reset.
    public init(using service: Service, @ViewBuilder success successViewBuilder: @escaping () -> SuccessView) {
        self.init(using: service, requestSubmitted: false, success: successViewBuilder)
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
    static let accountService = MockUserIdPasswordAccountService()


    static var previews: some View {
        NavigationStack {
            UserIdPasswordResetView(using: accountService) {
                SuccessfulPasswordResetView()
            }
                .environmentObject(Account(accountService))
        }

        NavigationStack {
            UserIdPasswordResetView(using: accountService, requestSubmitted: true) {
                SuccessfulPasswordResetView()
            }
                .environmentObject(Account(accountService))
        }
    }
}
#endif
