//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension View {
    /// Shorthand modifier for all ``AccountOverview`` related views to inject all the required values and objects into the environment.
    func injectEnvironmentObjects(service: any AccountService, model: AccountOverviewFormViewModel, focusState: FocusState<String?>) -> some View {
        self
            .injectEnvironmentObjects(service: service, model: model)
            .environmentObject(FocusStateObject(focusedField: focusState))
    }

    func injectEnvironmentObjects(service: any AccountService, model: AccountOverviewFormViewModel) -> some View {
        self
            .environment(\.accountServiceConfiguration, service.configuration)
            .environmentObject(model.modifiedDetailsBuilder)
            .environmentObject(model.validationEngines)
    }
}
