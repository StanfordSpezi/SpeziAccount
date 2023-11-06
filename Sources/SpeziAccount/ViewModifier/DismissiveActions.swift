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
    /// Disable any dismissive actions if the current `ViewState` is `processing`.
    func disableDismissiveActions(isProcessing state: ViewState) -> some View {
        self
            .navigationBarBackButtonHidden(state == .processing)
            .interactiveDismissDisabled(state == .processing)
    }
}
