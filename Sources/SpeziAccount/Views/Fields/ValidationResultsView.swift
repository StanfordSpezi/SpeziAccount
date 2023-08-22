//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

public struct ValidationResultsView: View {
    private let results: [FailedValidationResult]

    public var body: some View {
        VStack(alignment: .leading) {
            ForEach(results) { result in
                Text(result.message)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
            .font(.footnote)
            .foregroundColor(.red)
    }

    public init(results: [FailedValidationResult]) {
        self.results = results
    }
}


#if DEBUG
struct ValidationResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ValidationResultsView(results: [
            .init(from: .nonEmpty, message: ValidationRule.nonEmpty.message),
            .init(from: .mediumPassword, message: ValidationRule.mediumPassword.message)
        ])
    }
}
#endif
