//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension View {
    public func disableFieldAssistants() -> some View {
        self
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
    }
}
