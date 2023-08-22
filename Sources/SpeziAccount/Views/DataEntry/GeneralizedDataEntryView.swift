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
    func validationRules() -> [ValidationRule]?
}


/// A View to manage the state of a ``DataEntryView``.
///
/// Every ``DataEntryView`` is wrapped into a `GeneralizedDataEntryView` which is responsible to manage state of its child-view.
/// Particularly, the following things are taken care of:
/// - Declare and manage the state of the value and post any changes back up to the parent view.
/// - Declare a default `onTapeFocus(focusedField:fieldIdentifier:) to automatically manage focus state based on ``AccountKey/focusState``.
/// - If the value is of type `String` and the ``AccountService`` has a ``FieldValidationRules`` configuration for the given
///     ``DataEntryView/Key``, a  ``SwiftUI/View/validate(input:for:using:customFieldIdentifier:)-566ld`` modifier is automatically injected. One can easily override
///     the modified by declaring a custom one in the subview.
public struct GeneralizedDataEntryView<Wrapped: DataEntryView, Values: AccountValues>: View {
    @EnvironmentObject private var account: Account

    @EnvironmentObject private var focusState: FocusStateObject
    @EnvironmentObject private var detailsBuilder: AccountValuesBuilder<Values>

    @Environment(\.accountServiceConfiguration) private var configuration

    @State private var value: Wrapped.Key.Value


    public var body: some View {
        Group {
            if let stringValue = value as? String,
               let stringEntryView = self as? GeneralizedStringEntryView,
               let validationRules = stringEntryView.validationRules() {
                Wrapped($value)
                    .managedValidation(input: stringValue, for: Wrapped.Key.focusState, rules: validationRules)
            } else {
                Wrapped($value)
            }
        }
            .focused(focusState.projectedValue, equals: Wrapped.Key.focusState)
            .onChange(of: value) { newValue in
                // ensure parent view has access to the latest value
                detailsBuilder.set(Wrapped.Key.self, value: newValue)
            }
    }


    /// Initialize a new GeneralizedDataEntryView given a `Wrapped` view.
    /// - Parameter signupValue: The initial value to use. Typically you want to pass some "empty" value.
    public init(initialValue signupValue: Wrapped.Key.Value) {
        self._value = State(wrappedValue: signupValue)
    }
}


extension GeneralizedDataEntryView: GeneralizedStringEntryView where Wrapped.Key.Value == String {
    func validationRules() -> [ValidationRule]? { // swiftlint:disable:this discouraged_optional_collection
        if let rules = configuration.fieldValidationRules(for: Wrapped.Key.self) {
            return rules
        }

        if account.configuration[Wrapped.Key.self]?.requirement == .required {
            return [.nonEmpty]
        }

        return nil
    }
}
