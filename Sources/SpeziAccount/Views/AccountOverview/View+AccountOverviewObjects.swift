//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension View {
    func injectEnvironmentObjects(service: any AccountService, model: AccountOverviewFormViewModel) -> some View {
        self
            .environment(\.accountServiceConfiguration, service.configuration)
            .environment(model.modifiedDetailsBuilder)
    }
}
