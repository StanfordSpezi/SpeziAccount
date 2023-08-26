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


/// A View to manage the state of a ``DataEntryView``.
///
/// Every ``DataEntryView`` is wrapped into a `GeneralizedDataEntryView` which is responsible to manage state of its child-view.
/// Particularly, the following things are taken care of:
/// - Declare and manage the state of the value and post any changes back up to the parent view.
/// - Declare a default `focused(_:equals:)` modifier to String-based fields to automatically manage focus state based on ``AccountKey/focusState``.
/// - If the value is of type `String` and the ``AccountService`` has a ``FieldValidationRules`` configuration for the given
///     ``DataEntryView/Key``, a  ``SwiftUI/View/managedValidation(input:for:rules:)-5gj5g`` modifier is automatically injected. One can easily override
///     the modified by declaring a custom one in the subview.
public struct GeneralizedDataEntryView<Wrapped: DataEntryView, Values: AccountValues>: View {
    @EnvironmentObject private var account: Account

    @EnvironmentObject private var focusState: FocusStateObject
    @EnvironmentObject private var detailsBuilder: AccountValuesBuilder<Values>

    @Environment(\.accountServiceConfiguration)
    private var configuration
    @Environment(\.accountViewType)
    private var viewType

    @State private var value: Wrapped.Key.Value


    public var body: some View {
        Group {
            if let stringValue = value as? String,
               let stringEntryView = self as? GeneralizedStringEntryView {
                // if we have a string value, we have to check if FieldValidationRules is configured and
                // inject a ValidationEngine into the environment
                Wrapped($value)
                    .managedValidation(input: stringValue, for: Wrapped.Key.focusState, rules: stringEntryView.validationRules())
            } else if case .empty = Wrapped.Key.initialValue,
                      account.configuration[Wrapped.Key.self]?.requirement == .required {
                // If the field provides an empty value and is required, we inject a `nonEmpty` validation rule
                // if there isn't a validation engine already in the subview!
                Wrapped($value)
                    // checks that non-string values are supplied if configured to be `.required`
                    .requiredValidation(for: Wrapped.Key.self, storage: Values.self, $value)
            } else {
                Wrapped($value)
            }
        }
            .focused(focusState.projectedValue, equals: Wrapped.Key.focusState)
            .onAppear {
                // values like `GenderIdentity` provide a default value a user might not want to change
                if viewType?.enteringNewData == true,
                   case let .default(value) = Wrapped.Key.initialValue {
                    detailsBuilder.set(Wrapped.Key.self, value: value)
                }
            }
            .onChange(of: value) { newValue in
                // ensure parent view has access to the latest value
                if viewType?.enteringNewData == true,
                   case let .empty(emptyValue) = Wrapped.Key.initialValue,
                   newValue == emptyValue {
                    // e.g. make sure we don't save an empty value (e.g. an empty PersonNameComponents)
                    detailsBuilder.remove(Wrapped.Key.self)
                } else {
                    detailsBuilder.set(Wrapped.Key.self, value: newValue)
                }
            }
    }


    /// Initialize a new GeneralizedDataEntryView given a `Wrapped` view.
    /// - Parameter signupValue: The initial value to use. Typically you want to pass some "empty" value.
    init(initialValue signupValue: Wrapped.Key.Value) {
        self._value = State(wrappedValue: signupValue)
    }
}


extension GeneralizedDataEntryView: GeneralizedStringEntryView where Wrapped.Key.Value == String {
    func validationRules() -> [ValidationRule] {
        if let rules = configuration.fieldValidationRules(for: Wrapped.Key.self) {
            return rules
        }

        if account.configuration[Wrapped.Key.self]?.requirement == .required {
            return [.nonEmpty]
        }

        // we always want to inject a validation engine. Otherwise, account key would need to check the existence
        // of an environment object.
        return []
    }
}
