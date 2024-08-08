//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import RegexBuilder
import Spezi
import SpeziFoundation
import SpeziValidation
import SwiftUI


/// Entry or modify the value of an `FixedWidthInteger`-based `AccountKey`.
public struct FixedWidthIntegerEntryView<Key: AccountKey>: DataEntryView where Key.Value: FixedWidthInteger {
    @Environment(Account.self)
    private var account

    @Binding private var value: Key.Value
    @State private var text: String = ""

    private var validationRules: [ValidationRule] {
        if account.configuration[Key.self]?.requirement == .required {
            [.nonEmpty.intercepting, .isDigit(for: Key.Value.self)]
        } else {
            [.isDigit(for: Key.Value.self)]
        }
    }

    public var body: some View {
        VerifiableTextField(Key.name, text: $text)
            .validate(input: text, rules: validationRules)
#if !os(macOS)
            .keyboardType(.numberPad)
#endif
            .disableFieldAssistants()
            .onAppear {
                if case let .empty(empty) = Key.initialValue, empty == value {
                    text = ""
                } else {
                    text = value.description
                }
            }
            .onChange(of: text) {
                if text.isEmpty {
                    value = .zero
                    return
                }

                guard let value = Key.Value(text, radix: 10) else {
                    return // we check with validation that this is safe
                }
                self.value = value
            }
    }

    /// Create a new entry view.
    /// - Parameter value: The binding to the value to modify.
    public init(_ value: Binding<Key.Value>) {
        self._value = value
    }

    /// Create a new entry view.
    /// - Parameters:
    ///   - keyPath: The `AccountKey` type.
    ///   - value: The binding to the value to modify.
    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Binding<Key.Value>) {
        self.init(value)
    }
}


extension ValidationRule {
    static func isDigit<Value: FixedWidthInteger>(for value: Value.Type = Value.self, radix: Int = 10) -> ValidationRule {
        ValidationRule(
            rule: { input in
                input.isEmpty || Value(input, radix: radix) != nil
            },
            message: LocalizedStringResource("The input can only consist of digits.", bundle: .atURL(from: .module))
        )
    }
}


extension AccountKey where Value: FixedWidthInteger {
    /// Default DataEntry for `FixedWidthInteger`-based values.
    public typealias DataEntry = FixedWidthIntegerEntryView<Self>
}


#if DEBUG
#Preview {
    @State var value = 3
    return List {
        FixedWidthIntegerEntryView<MockNumericKey>($value)
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
