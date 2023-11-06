//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


struct GridValidationStateFooter: View {
    private var results: [FailedValidationResult]

    var body: some View {
        if !results.isEmpty { // otherwise we have some weird layout issues in Grids
            HStack {
                ValidationResultsView(results: results)
                Spacer()
            }
        }
    }

    init(_ results: [FailedValidationResult]) {
        self.results = results
    }
}
