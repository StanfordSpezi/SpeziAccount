//
// Created by Andreas Bauer on 27.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

public struct DefaultUserIdPasswordResetView<Service: UserIdPasswordAccountService, SuccessView: View>: View {
    private let service: Service
    private let successViewBuilder: () -> SuccessView

    // TODO success view!
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

                    // TODO generalized DataEntryAccountView!
                    VerifiableTextField("UserId", text: $userId)  // TODO localize!
                        .environmentObject(validationEngine) // TODO access to the button?
                        .textFieldStyle(.roundedBorder)
                        .disableFieldAssistants()
                        .fieldConfiguration(service.configuration.userIdField)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .userId)
                        .font(.title3)

                    // TODO padding?


                    AsyncDataEntrySubmitButton(state: $state, action: submitRequestAction) {
                        Text("Reset Password")
                            .padding(8)
                            .frame(maxWidth: .infinity) // TODO minHeight tvs padding(6)
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
            .navigationTitle("Password Rest") // TODO localize!
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
        // TODO great would be a way to conditionally access the environment object for the button?
        validationEngine.runValidation(input: userId)
        guard validationEngine.inputValid else {
            focusedField = .userId
            return
        }

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
