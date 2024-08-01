//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import RegexBuilder
import SpeziFoundation
import SpeziValidation
import SwiftUI


public struct FixedWidthIntegerDataEntry<Key: AccountKey>: DataEntryView where Key.Value: FixedWidthInteger {
    @Environment(Account.self)
    private var account

    @Binding private var value: Key.Value
    @State private var text: String

    public var validationRules: [ValidationRule] {
        if account.configuration[Key.self]?.requirement == .required {
            [.nonEmpty.intercepting, .isDigit(for: Key.Value.self)]
        } else {
            [.isDigit(for: Key.Value.self)]
        }
    }

    public var body: some View {
        // TODO: do a proper one that fails validation with string input!
        TextField(value: $value, formatter: NumberFormatter()) {
            Text(Key.name)
        }
        VerifiableTextField(Key.name, text: $text)
            .validate(input: text, rules: validationRules)
#if !os(macOS)
            .keyboardType(.numberPad)
#endif
            .disableFieldAssistants()
            .onChange(of: text) {
                guard let value = Key.Value(text, radix: 10) else {
                    return // we check with validation that this is safe
                }
                self.value = value
            }
    }

    public init(_ value: Binding<Key.Value>) {
        self._value = value
        self._text = State(wrappedValue: value.wrappedValue.description)
    }
}


extension ValidationRule {
    static func isDigit<Value: FixedWidthInteger>(for value: Value.Type = Value.self, radix: Int = 10) -> ValidationRule {
        ValidationRule(
            rule: { input in
                Value(input, radix: radix) != nil
            },
            message: LocalizedStringResource("The input can only consist of digits.", bundle: .atURL(from: .module))
        )
    }
}


extension AccountKey where Value: FixedWidthInteger { // TODO: update docs listing all the defaults!
    /// Default DataEntry for `FixedWidthInteger`-based values.
    public typealias DataEntry = FixedWidthIntegerDataEntry<Self>
}


#if DEBUG
#Preview {
    @State var value = 3
    return List {
        FixedWidthIntegerDataEntry<MockNumericKey>($value)
    }
}
#endif
