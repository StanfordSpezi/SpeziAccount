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

    @ValidationState(String.self) private var validation

    @Binding private var value: Key.Value
    @State private var enableMockValidation = false

    private var mockText: String {
        detailsBuilder.contains(Key.self) ? "CONTAINED" : ""
    }

    init(_ binding: Binding<Key.Value>) {
        self._value = binding
    }

    func body(content: Content) -> some View {
        VStack {
            content // the wrapped data entry view
                .validate(input: mockText, field: Key.focusState, rules: .nonEmpty)

            HStack {
                ValidationResultsView(results: validation.allDisplayedValidationResults)
                Spacer()
            }
        }
            .receiveValidation(in: $validation)
            .onChange(of: validation, initial: true) {
                // we disable our injected validation engine once we detect that the subview already defines a validation on their own
                if validation.count > 1 {
                    enableMockValidation = true
                } else if validation.count == 0 {
                    enableMockValidation = true
                }
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
