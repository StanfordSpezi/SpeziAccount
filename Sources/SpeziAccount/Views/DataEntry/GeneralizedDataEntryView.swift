//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


/// Helper protocol to easily retrieve Wrapped.Key types with String value
private protocol GeneralizedStringEntryView {
    @MainActor
    func validationRules() -> [ValidationRule]
}


/// A View to manage the state of a `DataEntryView`.
///
/// For every ``DataEntryView`` the following things are automatically taken care of:
/// - Declare and manage the state of the value and post any changes back up to the parent view.
/// - If the value is of type `String` and the ``AccountService`` has a ``FieldValidationRules`` configuration for the given
///     ``AccountKey``, a [validate(input:rules:)](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/spezivalidation/swiftui/view/validate(input:rules:)-5dac4)
///      modifier is automatically injected.
public struct GeneralizedDataEntryView<Key: AccountKey>: View {
    private var dataHookId: String {
        "DataHook-\(Key.self)"
    }

    @Environment(Account.self)
    private var account

    @Environment(AccountDetailsBuilder.self)
    private var detailsBuilder

    @Environment(\.accountServiceConfiguration)
    private var configuration
    @Environment(\.accountViewType)
    private var viewType

    @State private var value: Key.Value


    public var body: some View {
        Group {
            if let stringValue = value as? String,
               let stringEntryView = self as? GeneralizedStringEntryView {
                // if we have a string value, we have to check if FieldValidationRules is configured and
                // inject a ValidationEngine into the environment
                Key.DataEntry($value)
                    .validate(input: stringValue, rules: stringEntryView.validationRules())
            } else if case .empty = Key.initialValue,
                      account.configuration[Key.self]?.requirement == .required {
                // If the field provides an empty value and is required, we inject a `nonEmpty` validation rule
                // if there isn't a validation engine already in the subview!
                Key.DataEntry($value)
                    // checks that non-string values are supplied if configured to be `.required`
                    .validateRequired(for: Key.self, $value)
            } else {
                Key.DataEntry($value)
            }
        }
            .onAppear {
                // values like `GenderIdentity` provide a default value a user might not want to change
                if viewType?.enteringNewData == true,
                   case let .default(value) = Key.initialValue {
                    detailsBuilder.set(Key.self, defaultValue: value)
                }
            }
            .onChange(of: value) {
                // ensure parent view has access to the latest value
                if viewType?.enteringNewData == true,
                   case let .empty(emptyValue) = Key.initialValue,
                   value == emptyValue {
                    // e.g. make sure we don't save an empty value (e.g. an empty PersonNameComponents)
                    detailsBuilder.remove(Key.self)
                } else {
                    detailsBuilder.set(Key.self, value: value)
                }
            }
    }


    /// Initialize a new GeneralizedDataEntryView given a `Wrapped` view.
    /// - Parameter signupValue: The initial value to use. Typically you want to pass some "empty" value.
    init(initialValue signupValue: Key.Value) {
        self._value = State(wrappedValue: signupValue)
    }
}


extension GeneralizedDataEntryView: GeneralizedStringEntryView where Key.Value == String {
    func validationRules() -> [ValidationRule] {
        if let rules = configuration.fieldValidationRules(for: Key.self) {
            return rules
        }

        if account.configuration[Key.self]?.requirement == .required {
            return [.nonEmpty]
        }

        // we always want to inject a validation engine. Otherwise, account key would need to check the existence
        // of an environment object.
        return []
    }
}
