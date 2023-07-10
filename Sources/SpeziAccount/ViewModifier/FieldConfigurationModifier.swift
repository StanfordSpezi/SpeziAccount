//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension View {
    public func fieldConfiguration(_ configuration: FieldConfiguration) -> some View {
        self
            .textContentType(configuration.textContentType)
            .keyboardType(configuration.keyboardType)
    }
}
