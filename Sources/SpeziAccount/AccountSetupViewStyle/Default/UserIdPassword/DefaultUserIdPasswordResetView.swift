//
// Created by Andreas Bauer on 27.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

public struct DefaultUserIdPasswordResetView<Service: UserIdPasswordAccountService, SuccessView: View>: View {
    private let service: Service

    // TODO validation rules (isEmpty!)

    private let successViewBuilder: () -> SuccessView

    // TODO success view!
    @State private var userId = ""
    @State private var requestSubmitted = false

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: AccountInputFields?

    public var body: some View {
        VStack {
            if requestSubmitted {
                successViewBuilder()
            } else {
                // TODO generalized DataEntryAccountView!

                Button(action: submitRequestAction) {
                    Text("Reset Password")
                        .frame(maxWidth: .infinity, minHeight: 38) // TODO miNiehg tvs padding(6)
                        .replaceWithProcessingIndicator(ifProcessing: state)
                }
                .buttonStyle(.borderedProminent)
                .disabled(state == .processing)
                .padding(.bottom, 12)
                .padding(.top)
            }
        }
            .navigationBarBackButtonHidden(state == .processing)
            .viewStateAlert(state: $state)
            .onTapGesture {
                focusedField = nil
            }
    }

    public init(using service: Service, @ViewBuilder onSuccess successViewBuilder: @escaping () -> SuccessView) {
        self.service = service
        self.successViewBuilder = successViewBuilder
    }

    private func submitRequestAction() {
        guard state != .processing else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            focusedField = .none
            state = .processing
        }

        Task {
            do {
                try await service.resetPassword(userId: userId)

                withAnimation(.easeOut(duration: 0.5)) {
                    requestSubmitted = true
                }
                try await Task.sleep(for: .milliseconds(600))
                state = .idle
            } catch {
                state = .error(
                    AnyLocalizedError(
                        error: error,
                        defaultErrorDescription: "DEFAULT ERROR" // TODO localized!
                    )
                )
            }
        }
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
