//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


private struct RequiredValidationModifier<Key: AccountKey>: ViewModifier {
    @Environment(AccountDetailsBuilder.self) private var detailsBuilder

    @ValidationState private var validation
    @ValidationState private var innerValidation

    @Binding private var value: Key.Value

    private var mockText: String {
        detailsBuilder.contains(Key.self) ? "CONTAINED" : ""
    }

    init(_ binding: Binding<Key.Value>) {
        self._value = binding
    }

    func body(content: Content) -> some View {
        VStack {
            let view = content // the wrapped data entry view
                .receiveValidation(in: $innerValidation)

            if innerValidation.isEmpty {
                // ensure we don't nest validate modifiers. Otherwise, we get visibility problems.
                view
                    .validate(input: mockText, rules: .nonEmpty)

                HStack {
                    ValidationResultsView(results: validation.allDisplayedValidationResults)
                    Spacer()
                }
            } else {
                view
            }
        }
            .receiveValidation(in: $validation)
            .onChange(of: innerValidation, initial: true) {
                print("InnerValidation: \(innerValidation)")
            }
            .onChange(of: validation, initial: true) {
                print("Validation: \(validation)")
            }
    }
}


extension View {
    @ViewBuilder
    func validateRequired<Key: AccountKey>(for key: Key.Type, _ value: Binding<Key.Value>) -> some View {
        modifier(RequiredValidationModifier<Key>(value))
    }
}
