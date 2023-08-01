//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct InputValidationModifier<Key: AccountValueKey>: ViewModifier {
    private let inputValue: String
    private let fieldIdentifierOverride: String?

    @Environment(\.dataEntryConfiguration)
    private var dataEntryConfiguration

    @StateObject private var validation: ValidationEngine

    init(input value: String, rules: [ValidationRule], fieldIdentifierOverride: String? = nil) {
        self.inputValue = value
        self._validation = StateObject(wrappedValue: ValidationEngine(rules: rules))
        self.fieldIdentifierOverride = fieldIdentifierOverride
    }

    func body(content: Content) -> some View {
        content
            .environmentObject(validation)
            .onAppear {
                dataEntryConfiguration.validationClosures.register(Key.self, validation: onDataSubmission)
            }
    }

    func onDataSubmission() -> DataValidationResult {
        validation.runValidation(input: inputValue)

        if validation.inputValid {
            return .success
        } else if let fieldIdentifierOverride {
            return .failedAtField(focusedField: fieldIdentifierOverride)
        } else {
            return .failed
        }
    }
}


extension View {
    public func validate<Key: AccountValueKey>(
        input value: String,
        for key: Key.Type,
        using rules: [ValidationRule],
        customFieldIdentifier: String? = nil
    ) -> some View {
        modifier(InputValidationModifier<Key>(input: value, rules: rules, fieldIdentifierOverride: customFieldIdentifier))
    }

    public func validate<Key: AccountValueKey>(
        input value: String,
        for keyPath: KeyPath<AccountValueKeys, Key.Type>,
        using rules: [ValidationRule],
        customFieldIdentifier: String? = nil
    ) -> some View {
        validate(input: value, for: Key.self, using: rules, customFieldIdentifier: customFieldIdentifier)
    }
}
