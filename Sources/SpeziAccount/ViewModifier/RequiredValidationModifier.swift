//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct RequiredValidationModifier<Key: AccountKey, Values: AccountValues>: ViewModifier {
    @EnvironmentObject private var engines: ValidationEngines<String>
    @EnvironmentObject private var detailsBuilder: AccountValuesBuilder<Values>

    @Binding private var value: Key.Value

    @StateObject private var validation = ValidationEngine(rules: .nonEmpty) // mock validation engine

    private var mockText: String {
        detailsBuilder.contains(Key.self) ? "CONTAINED" : ""
    }

    init(_ binding: Binding<Key.Value>) {
        self._value = binding
    }

    func body(content: Content) -> some View {
        VStack {
            content // the wrapped data entry view
                .onChange(of: value) { _ in
                    // only if we are still registered
                    if engines.contains(validation) {
                        // as soon as the user changed the input once, we will always have a value.
                        validation.submit(input: mockText, debounce: true)
                    }
                }

            HStack {
                ValidationResultsView(results: validation.displayedValidationResults)
                Spacer()
            }
        }
            .register(engine: validation, with: engines, input: mockText)
    }
}


extension View {
    @ViewBuilder
    func requiredValidation<Key: AccountKey, Values: AccountValues>(
        for key: Key.Type,
        storage values: Values.Type,
        _ value: Binding<Key.Value>
    ) -> some View {
        // this is a workaround to allow subviews to define their own ValidationEngine
        let containsValidation = Mirror(reflecting: self).children.contains { _, value in
            value is StateObject<ValidationEngine>
        }

        if containsValidation {
            self
        } else {
            self
                .modifier(RequiredValidationModifier<Key, Values>(value))
        }
    }
}
