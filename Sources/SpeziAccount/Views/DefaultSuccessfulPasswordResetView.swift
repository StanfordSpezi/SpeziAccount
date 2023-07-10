//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

public struct DefaultSuccessfulPasswordResetView: View {
    private let successfulLabelLocalization: LocalizedStringResource

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
