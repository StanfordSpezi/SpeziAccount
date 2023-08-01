//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// Helper protocol to easily retrieve Wrapped.Key types with String value
private protocol GeneralizedStringEntryView {
    func validationRules() -> [ValidationRule]
}


/// A View to manage state of a ``DataEntryView``.
///
/// Every ``DataEntryView`` is wrapped into a `GeneralizedDataEntryView` which is responsible to manage state of its child-view.
/// Particularly, the following things are taken care of:
/// - Declare and manage the state of the value and post any changes back up to the parent view.
/// - Declare a default `onTapeFocus(focusedField:fieldIdentifier:) to automatically manage focus state based on ``AccountValueKey/focusState``.
/// - If the value is of type string and the ``AccountService`` has a ``FieldValidationRules`` configuration for the given
///     ``DataEntryView/Key``, a `View/validate(input:for:using)` modifier is automatically injected. One can easily override
///     the modified by declaring a custom one.
public struct GeneralizedDataEntryView<Wrapped: DataEntryView>: View {
    @Environment(\.dataEntryConfiguration)
    private var dataEntryConfiguration: DataEntryConfiguration
    @EnvironmentObject
    private var signupRequest: SignupRequestBuilder

    @State private var value: Wrapped.Key.Value


    public var body: some View {
        Group {
            if let stringValue = value as? String,
               let stringEntryView = self as? GeneralizedStringEntryView {
                Wrapped($value)
                    .validate(
                        input: stringValue,
                        for: Wrapped.Key.self,
                        using: stringEntryView.validationRules()
                    )
            } else {
                Wrapped($value)
            }
        }
            .onTapFocus(focusedField: dataEntryConfiguration.focusedField, fieldIdentifier: Wrapped.Key.focusState)
            .onChange(of: value) { newValue in
                // ensure parent view has access to the latest value
                signupRequest.post(for: Wrapped.Key.self, value: newValue)
            }
    }


    /// Initialize a new GeneralizedDataEntryView given a ``Wrapped`` view.
    /// - Parameter signupValue: The initial value to use. Typically you want to pass some "empty" value.
    public init(initialValue signupValue: Wrapped.Key.Value) {
        self._value = State(wrappedValue: signupValue)
    }
}


extension GeneralizedDataEntryView: GeneralizedStringEntryView where Wrapped.Key.Value == String {
    func validationRules() -> [ValidationRule] {
        dataEntryConfiguration.serviceConfiguration.fieldValidationRules(for: Wrapped.Key.self)
    }
}


extension AccountValueKey where Value: DefaultInitializable {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: .init())
    }
}

extension AccountValueKey where Value == String {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: "")
    }
}

extension AccountValueKey where Value == Date {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: Date())
    }
}

extension AccountValueKey where Value: AdditiveArithmetic {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        // this catches all the numeric types
        GeneralizedDataEntryView(initialValue: .zero)
    }
}

extension AccountValueKey where Value: ExpressibleByArrayLiteral {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: [])
    }
}

extension AccountValueKey where Value: ExpressibleByDictionaryLiteral {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: [:])
    }
}
