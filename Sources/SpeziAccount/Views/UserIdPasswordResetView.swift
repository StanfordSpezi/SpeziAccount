//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SpeziValidation
import SwiftUI


/// A password reset view implementation for a ``UserIdPasswordAccountService``.
public struct UserIdPasswordResetView<Service: UserIdPasswordAccountService, SuccessView: View>: View {
    private let service: Service
    private let successView: SuccessView

    private var userIdConfiguration: UserIdConfiguration {
        service.configuration.userIdConfiguration
    }

    @Environment(\.dismiss) private var dismiss

    @ValidationState private var validation

    @State private var userId = ""
    @State private var requestSubmitted: Bool

    @State private var state: ViewState = .idle
    @FocusState private var isFocused: Bool


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
                    .receiveValidation(in: $validation)
                    .viewStateAlert(state: $state)
                    .toolbar {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("DONE", bundle: .module)
                        }
                    }
            }
        }
    }

    @MainActor @ViewBuilder private var resetPasswordForm: some View {
        VStack {
            Text("UAP_PASSWORD_RESET_SUBTITLE \(userIdConfiguration.idType.localizedStringResource)", bundle: .module)
                .padding()
                .padding(.bottom, 30)

            VerifiableTextField(userIdConfiguration.idType.localizedStringResource, text: $userId)
                .validate(input: userId, rules: .nonEmpty)
                .focused($isFocused)
                .textFieldStyle(.roundedBorder)
                .disableFieldAssistants()
                .textContentType(userIdConfiguration.textContentType)
                .keyboardType(userIdConfiguration.keyboardType)
                .font(.title3)

            Spacer()
            AsyncButton(state: $state, action: submitRequestAction) {
                Text("Reset Password")
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding()
        }
            .padding()
            .frame(maxWidth: ViewSizing.maxFrameWidth * 1.5) // landscape optimizations
            .environment(\.defaultErrorDescription, .init("UAP_RESET_PASSWORD_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
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


    @MainActor
    private func submitRequestAction() async throws {
        guard validation.validateSubviews() else {
            return
        }

        isFocused = false

        try await service.resetPassword(userId: userId)

        withAnimation(.easeOut(duration: 0.5)) {
            requestSubmitted = true
        }

        Task {
            // we are creating a detached task, as otherwise this one might be cancelled
            // as the view update above results in our current ask getting freed
            try await Task.sleep(for: .milliseconds(515))
            state = .idle
        }
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
