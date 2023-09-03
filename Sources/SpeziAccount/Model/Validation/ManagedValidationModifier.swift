//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct InputValidationModifier<FieldIdentifier: Hashable>: ViewModifier {
    private let inputValue: String
    private let fieldIdentifier: FieldIdentifier?

    @EnvironmentObject private var engines: ValidationEngines<FieldIdentifier>
    @Environment(\.validationEngineConfiguration) private var configuration

    @StateObject private var validation: ValidationEngine

    init(input value: String, for fieldIdentifier: FieldIdentifier?, rules: [ValidationRule]) {
        self.inputValue = value
        self.fieldIdentifier = fieldIdentifier
        self._validation = StateObject(wrappedValue: ValidationEngine(rules: rules))
    }

    func body(content: Content) -> some View {
        let _ = validation.configuration = configuration // swiftlint:disable:this redundant_discardable_let

        content
            .environmentObject(validation)
            .register(engine: validation, engines: engines, field: fieldIdentifier, input: inputValue)
    }
}


extension View {
    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func managedValidation<FieldIdentifier: Hashable>(
        input value: String,
        for fieldIdentifier: FieldIdentifier,
        rules: [ValidationRule]
    ) -> some View {
        modifier(InputValidationModifier(input: value, for: fieldIdentifier, rules: rules))
    }

    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func managedValidation(
        input value: String,
        rules: [ValidationRule]
    ) -> some View {
        modifier(InputValidationModifier<Never>(input: value, for: nil, rules: rules))
    }

    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An variadic array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func managedValidation<FieldIdentifier: Hashable>(
        input value: String,
        for fieldIdentifier: FieldIdentifier,
        rules: ValidationRule...
    ) -> some View {
        managedValidation(input: value, for: fieldIdentifier, rules: rules)
    }

    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An variadic array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func managedValidation(
        input value: String,
        rules: ValidationRule...
    ) -> some View {
        managedValidation(input: value, rules: rules)
    }
}
