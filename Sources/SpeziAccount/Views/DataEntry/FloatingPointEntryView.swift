//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFoundation
import SpeziValidation
import SwiftUI


/// Entry or modify the value of an `BinaryFloatingPoint`-based `AccountKey`.
public struct FloatingPointEntryView<Key: AccountKey>: DataEntryView where Key.Value: BinaryFloatingPoint {
    private let formatStyle: Decimal.FormatStyle?

    @Environment(Account.self)
    private var account

    @Environment(\.locale)
    private var locale

    @Binding private var value: Key.Value

    @State private var decimal: Decimal = .zero
    @State private var text: String = ""

    private var formatStyleValue: Decimal.FormatStyle {
        formatStyle ?? Decimal.FormatStyle(locale: locale)
    }

    private var validCharacters: CharacterSet {
        CharacterSet(charactersIn: "0123456789" + (locale.decimalSeparator ?? "."))
    }

    private var validationRules: [ValidationRule] {
        if account.configuration[Key.self]?.requirement == .required {
            [.nonEmpty.intercepting, .isDecimal(for: Key.Value.self, formatStyle: formatStyleValue, characters: validCharacters)]
        } else {
            [.isDecimal(for: Key.Value.self, formatStyle: formatStyleValue, characters: validCharacters)]
        }
    }

    public var body: some View {
        VerifiableTextField(Key.name, text: $text)
            .validate(input: text, rules: validationRules)
#if !os(macOS)
            .keyboardType(.decimalPad)
#endif
            .disableFieldAssistants()
            .onAppear {
                if case let .empty(empty) = Key.initialValue, empty == value {
                    text = ""
                } else {
                    text = Decimal(Double(value)).formatted(formatStyleValue)
                }
            }
            .onChange(of: text) {
                if text.isEmpty {
                    value = .zero
                    return
                }

                if text.rangeOfCharacter(from: validCharacters.inverted) != nil {
                    return
                }

                guard let decimal = try? Decimal(text, format: formatStyleValue, lenient: false) else {
                    return
                }

                let double = Double(truncating: decimal as NSDecimalNumber)
                self.value = Key.Value(double)
            }
    }

    /// Create a new entry view.
    /// - Parameters:
    ///   - value: The binding to the value to modify.
    ///   - formatStyle: The decimal format style. If `nil` a default is used.
    public init(
        _ value: Binding<Key.Value>,
        format formatStyle: Decimal.FormatStyle? = nil
    ) {
        self._value = value
        self.formatStyle = formatStyle
    }

    /// Create a new entry view.
    /// - Parameter value: The binding to the value to modify.
    public init(_ value: Binding<Key.Value>) {
        self._value = value
        self.formatStyle = nil
    }

    /// Create a new entry view.
    /// - Parameters:
    ///   - keyPath: The `AccountKey` type.
    ///   - value: The binding to the value to modify.
    ///   - formatStyle: The decimal format style. If `nil` a default is used.
    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Binding<Key.Value>, format formatStyle: Decimal.FormatStyle? = nil) {
        self.init(value, format: formatStyle)
    }
}


extension ValidationRule {
    static func isDecimal<Value: BinaryFloatingPoint>(
        for value: Value.Type,
        formatStyle: Decimal.FormatStyle,
        characters: CharacterSet
    ) -> ValidationRule {
        ValidationRule(
            rule: { input in
                if input.isEmpty {
                    return true
                }

                if input.rangeOfCharacter(from: characters.inverted) != nil {
                    return false // contains illegal characters
                }

                if input.filter({ String($0) == (formatStyle.locale.decimalSeparator ?? ".") }).count > 1 {
                    return false
                }

                return (try? Decimal(input, format: formatStyle, lenient: false)) != nil
            },
            message: LocalizedStringResource("The input can only consist of digits.", bundle: .atURL(from: .module))
        )
    }
}


extension AccountKey where Value: BinaryFloatingPoint {
    /// Default DataEntry for `BinaryFloatingPoint`-based values.
    public typealias DataEntry = FloatingPointEntryView<Self>
}


#if DEBUG
#Preview {
    @Previewable @State var value = 3.15
    List {
        FloatingPointEntryView<MockDoubleKey>($value)
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
