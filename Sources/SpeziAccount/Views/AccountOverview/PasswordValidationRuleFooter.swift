//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct PasswordValidationRuleFooter: View {
    private let configuration: AccountServiceConfiguration

    var body: some View {
        let rules = configuration.fieldValidationRules(for: PasswordKey.self)
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
struct PasswordValidationRuleFooter_Previews: PreviewProvider {
    static var previews: some View {
        PasswordValidationRuleFooter(configuration: AccountServiceConfiguration(name: "Preview Service") {
            FieldValidationRules(for: \.password, rules: .minimalPassword, .strongPassword) // doesn't make sense, but useful for preview
        })
    }
}
#endif
