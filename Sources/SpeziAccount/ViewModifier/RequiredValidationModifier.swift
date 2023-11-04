//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


private struct RequiredValidationModifier<Key: AccountKey, Values: AccountValues>: ViewModifier {
    @EnvironmentObject private var detailsBuilder: AccountValuesBuilder<Values>

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
            content // the wrapped data entry view
                .receiveValidation(in: $innerValidation)
                .validate(input: mockText, rules: .nonEmpty)

            if innerValidation.isEmpty {
                HStack {
                    ValidationResultsView(results: validation.allDisplayedValidationResults)
                    Spacer()
                }
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
    func requiredValidation<Key: AccountKey, Values: AccountValues>(
        for key: Key.Type,
        storage values: Values.Type,
        _ value: Binding<Key.Value>
    ) -> some View {
        modifier(RequiredValidationModifier<Key, Values>(value))
    }
}
