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

extension View {
    // TODO naming is a bit off!
    public func replaceWithProcessingIndicator<Processing: View>(
        ifProcessing state: ViewState,
        @ViewBuilder with view: () -> Processing = { ProgressView() }
    ) -> some View {
        replaceWithProcessingIndicator(if: state == .processing, with: view)
    }

    public func replaceWithProcessingIndicator<Processing: View>(
        if processing: Bool,
        @ViewBuilder with view: () -> Processing = { ProgressView() }
    ) -> some View {
        self
            .opacity(processing ? 0.0 : 1.0)
            .overlay {
                if processing {
                    view()
                }
            }
    }
}

extension View {
    public func disableAnyDismissiveActions(ifProcessing state: ViewState) -> some View {
        self
            .navigationBarBackButtonHidden(state == .processing)
            .interactiveDismissDisabled(state == .processing)
    }
}
