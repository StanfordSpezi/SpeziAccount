//
// Created by Andreas Bauer on 27.06.23.
//

import Foundation
import SwiftUI

public struct DefaultSuccessfulPasswordResetView: View {
    private let successfulLabelLocalization: LocalizedStringResource

    // TODO remove @Environment(\.dismiss) var dismiss

    public var body: some View {
        Spacer()

        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .foregroundColor(.green)
                .frame(width: 100, height: 100)
            Text(successfulLabelLocalization)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
            .padding(32)

        /*
        Button(action: {
            dismiss()
        }) {
            Text("Continue") // TODO whatever!
        }
        */
        // TODO how to dismiss?

        Spacer()
        Spacer()
    }

    public init(
        successfulLabelLocalization: LocalizedStringResource? = nil
    ) {
        self.successfulLabelLocalization = successfulLabelLocalization
            ?? LocalizedStringResource("UAP_RESET_PASSWORD_PROCESS_SUCCESSFUL_LABEL", bundle: .atURL(from: .module))
    }
}

#if DEBUG
struct DefaultSuccessfulPasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultSuccessfulPasswordResetView()
        }
    }
}
#endif
