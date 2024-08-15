//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


struct PasswordValidationRuleFooter: View {
    private let configuration: AccountServiceConfiguration

    var body: some View {
        let rules = (configuration.fieldValidationRules(for: AccountKeys.password) ?? [])
            .filter { $0.id != ValidationRule.nonEmpty.id }

        VStack {
            ForEach(rules) { rules in
                HStack {
                    Text(rules.message)
                    Spacer()
                }
            }
                .multilineTextAlignment(.leading)
        }
    }

    init(configuration: AccountServiceConfiguration) {
        self.configuration = configuration
    }
}


#if DEBUG
#Preview {
    PasswordValidationRuleFooter(configuration: AccountServiceConfiguration(supportedKeys: .arbitrary) {
        FieldValidationRules(for: \.password, rules: .minimalPassword, .strongPassword) // doesn't make sense, but useful for preview
    })
}
#endif
