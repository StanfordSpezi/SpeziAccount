//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A simple success view for a password reset view.
public struct SuccessfulPasswordResetView: View {
    private let successfulLabelLocalization: LocalizedStringResource

    public var body: some View {
        Spacer()

        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .foregroundColor(.green)
                .frame(width: 100, height: 100)
                .accessibilityHidden(true)
            Text(successfulLabelLocalization)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
            .padding(32)

        Spacer()
        Spacer()
    }


    /// Create a new success view.
    /// - Parameter successfulLabel: Optionally a customized label localization.
    public init(successfulLabel: LocalizedStringResource? = nil) {
        self.successfulLabelLocalization = successfulLabel
            ?? LocalizedStringResource("UAP_RESET_PASSWORD_PROCESS_SUCCESSFUL_LABEL", bundle: .atURL(from: .module))
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        SuccessfulPasswordResetView()
    }
}
#endif
