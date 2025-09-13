//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SpeziViews
import SwiftUI


/// A password reset view implementation.
///
/// You can use this view to implement a basic password reset operation.
///
/// - Tip: You can throw an `LocalizedError` to communicate erroneous conditions back to the user.
///
/// Below is a short code example on how to use this view.
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         PasswordResetView { userId in
///             // handle password reset for the requested user id
///         }
///     }
/// }
/// ```
///
/// - Note: Use ``init(resetPassword:success:)`` to provide a custom view that appears for a successful password reset.
public struct PasswordResetView<SuccessView: View>: View {
    private let successView: SuccessView
    private let resetPasswordClosure: (String) async throws -> Void

    @Environment(Account.self) private var account
    @Environment(\.dismiss) private var dismiss

    @ValidationState private var validation

    @State private var userId = ""
    @State private var requestSubmitted: Bool

    @State private var state: ViewState = .idle
    @FocusState private var isFocused: Bool

    @MainActor private var userIdConfiguration: UserIdConfiguration {
        account.accountService.configuration.userIdConfiguration
    }


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
                    .toolbarTitleDisplayMode(.inline)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                    .disableDismissiveActions(isProcessing: state)
                    .receiveValidation(in: $validation)
                    .viewStateAlert(state: $state)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                                Button(role: .cancel) {
                                    dismiss()
                                }
                            } else {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("Cancel", bundle: .module)
                                }
                            }
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
#if !os(tvOS) && !os(watchOS)
                .textFieldStyle(.roundedBorder)
#endif
                .disableFieldAssistants()
                .textContentType(userIdConfiguration.textContentType)
#if !os(macOS) && !os(watchOS)
                .keyboardType(userIdConfiguration.keyboardType)
#endif
                .font(.title3)

            Spacer()
            AsyncButton(state: $state, action: submitRequestAction) {
                Text("UP_RESET_PASSWORD", bundle: .module)
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyleGlassProminent(backup: .borderedProminent)
                .padding()
        }
            .padding()
            .frame(maxWidth: ViewSizing.maxFrameWidth * 1.5) // landscape optimizations
            .environment(\.defaultErrorDescription, .init("UAP_RESET_PASSWORD_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
    }

    fileprivate init(
        requestSubmitted: Bool,
        resetPassword: @escaping (String) async throws -> Void,
        @ViewBuilder success successViewBuilder: () -> SuccessView = { SuccessfulPasswordResetView() }
    ) {
        self.resetPasswordClosure = resetPassword
        self.successView = successViewBuilder()
        self._requestSubmitted = State(wrappedValue: requestSubmitted)
    }


    /// Create a new view.
    /// - Parameters:
    ///   - resetPassword: A closure that is executed when the user request to reset their password. The closure receives the ``AccountDetails/userId`` as an argument.
    ///   - success: A view to display on successful password reset.
    public init(
        resetPassword: @escaping (String) async throws -> Void,
        @ViewBuilder success: @escaping () -> SuccessView = { SuccessfulPasswordResetView() }
    ) {
        self.init(requestSubmitted: false, resetPassword: resetPassword, success: success)
    }


    @MainActor
    private func submitRequestAction() async throws {
        guard validation.validateSubviews() else {
            return
        }

        isFocused = false

        let userId = userId
        try await resetPasswordClosure(userId)

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
#Preview {
    NavigationStack {
        PasswordResetView { userId in
            print("Reset password for \(userId)")
        }
            .previewWith {
                AccountConfiguration(service: InMemoryAccountService())
            }
    }
}

#Preview {
    NavigationStack {
        PasswordResetView(requestSubmitted: true) { userId in
            print("Reset password for \(userId)")
        }
            .previewWith {
                AccountConfiguration(service: InMemoryAccountService())
            }
    }
}
#endif
