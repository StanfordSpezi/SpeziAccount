//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension View {
    /// Disable any assistants on a field like autocorrect or input autocapitalization.
    func disableFieldAssistants() -> some View {
        self
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
    }
}
