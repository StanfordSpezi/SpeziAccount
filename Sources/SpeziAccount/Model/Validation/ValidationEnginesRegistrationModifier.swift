//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct ValidationEnginesRegistrationModifier<FieldIdentifier: Hashable>: ViewModifier {
    private let engines: ValidationEngines<FieldIdentifier>
    private let validation: ValidationEngine
    private let fieldIdentifier: FieldIdentifier?
    private let input: String


    init(engines: ValidationEngines<FieldIdentifier>, validation: ValidationEngine, fieldIdentifier: FieldIdentifier?, input: String) {
        self.engines = engines
        self.validation = validation
        self.fieldIdentifier = fieldIdentifier
        self.input = input
    }


    func body(content: Content) -> some View {
        // We don't retrieve a binding for the `input` value.
        // Therefore we refresh the supplied closure everytime the body gets rebuilt.
        engines.register(engine: validation, field: fieldIdentifier, input: input)

        content
            .onDisappear {
                engines.remove(engine: validation)
            }
    }
}


extension View {
    func register<FieldIdentifier>(
        engine: ValidationEngine,
        engines: ValidationEngines<FieldIdentifier>,
        field: FieldIdentifier?,
        input: String
    ) -> some View {
        self
            .modifier(ValidationEnginesRegistrationModifier(engines: engines, validation: engine, fieldIdentifier: field, input: input))
    }

    /// Register a new validation engine by providing an field identifier for focus state handling.
    ///
    /// - Parameters:
    ///   - engine: The ``ValidationEngine`` to register.
    ///   - engines: The collection of ``ValidationEngines`` to register at.
    ///   - field: The field which should receive focus if the validation reports invalid state on button press.
    ///   - input: The current text input to validate.
    public func register<FieldIdentifier>(
        engine: ValidationEngine,
        with engines: ValidationEngines<FieldIdentifier>,
        for field: FieldIdentifier,
        input: String
    ) -> some View {
        self
            .register(engine: engine, engines: engines, field: field, input: input)
    }

    /// Register a new validation engine.
    ///
    /// - Parameters:
    ///   - engine: The ``ValidationEngine`` to register.
    ///   - engines: The collection of ``ValidationEngines`` to register at.
    ///   - input: The current text input to validate.
    public func register<FieldIdentifier>(
        engine: ValidationEngine,
        with engines: ValidationEngines<FieldIdentifier>,
        input: String
    ) -> some View {
        self
            .register(engine: engine, engines: engines, field: nil, input: input)
    }
}
