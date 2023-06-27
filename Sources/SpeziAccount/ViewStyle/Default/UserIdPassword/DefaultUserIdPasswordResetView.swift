//
// Created by Andreas Bauer on 27.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

public struct DefaultUserIdPasswordResetView<Service: UserIdPasswordAccountService>: View {
    var service: Service

    // TODO validation rules (isEmpty!)

    // TODO success view!
    @State private var userId = ""

    @State private var requestSubmitted = false

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: AccountInputFields?

    public var body: some View {
        if requestSubmitted {
            Text("Submitted!") // TODO place success view modularized!
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

    private func submitRequestAction() {

    }
}

#if DEBUG
struct DefaultUserIdPasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultUserIdPasswordResetView(service: DefaultUsernamePasswordAccountService())
        }
    }
}
#endif
