//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if os(macOS) // macro tests can only be run on the host machine

import SpeziAccountMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: any Macro.Type] = [
    "AccountKey": AccountKeyMacro.self,
    "KeyEntry": KeyEntryMacro.self
]


final class AccountKeyMacroTests: XCTestCase { // swiftlint:disable:this type_body_length
    func testAccountKeyGeneration() {
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Gender Identity", category: .personalDetails, as: GenderIdentity.self, initial: .default(.preferNotToState))
                var genderIdentity: GenderIdentity?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var genderIdentity: GenderIdentity? {
                    get {
                        self [__Key_genderIdentity.self]
                    }
                    set {
                        self [__Key_genderIdentity.self] = newValue
                    }
                }
            
                struct __Key_genderIdentity: AccountKey {
                    typealias Value = GenderIdentity
            
                    static let name: LocalizedStringResource = "Gender Identity"
                    static let identifier: String = "genderIdentity"
                    static let category: AccountKeyCategory = .personalDetails
                    static var initialValue: InitialValue<Value> {
                        .default(.preferNotToState)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testAccountKeyId() {
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(
                    id: "GI",
                    name: "Gender Identity",
                    category: .personalDetails,
                    as: GenderIdentity.self,
                    initial: .default(.preferNotToState)
                )
                var genderIdentity: GenderIdentity?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var genderIdentity: GenderIdentity? {
                    get {
                        self [__Key_genderIdentity.self]
                    }
                    set {
                        self [__Key_genderIdentity.self] = newValue
                    }
                }
            
                struct __Key_genderIdentity: AccountKey {
                    typealias Value = GenderIdentity
            
                    static let name: LocalizedStringResource = "Gender Identity"
                    static let identifier: String = "GI"
                    static let category: AccountKeyCategory = .personalDetails
                    static var initialValue: InitialValue<Value> {
                        .default(.preferNotToState)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testAccountKeyGenerationPublic() {
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Gender Identity", category: .personalDetails, as: GenderIdentity.self, initial: .default(.preferNotToState))
                public var genderIdentity: GenderIdentity?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                public var genderIdentity: GenderIdentity? {
                    get {
                        self [__Key_genderIdentity.self]
                    }
                    set {
                        self [__Key_genderIdentity.self] = newValue
                    }
                }
            
                public struct __Key_genderIdentity: AccountKey {
                    public typealias Value = GenderIdentity
            
                    public static let name: LocalizedStringResource = "Gender Identity"
                    public static let identifier: String = "genderIdentity"
                    public static let category: AccountKeyCategory = .personalDetails
                    public static var initialValue: InitialValue<Value> {
                        .default(.preferNotToState)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testRequiredAccountKey() {
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Account Id", as: String.self)
                var accountId: String
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var accountId: String {
                    get {
                        self [__Key_accountId.self]
                    }
                    set {
                        self [__Key_accountId.self] = newValue
                    }
                }
            
                struct __Key_accountId: RequiredAccountKey {
                    typealias Value = String
            
                    static let name: LocalizedStringResource = "Account Id"
                    static let identifier: String = "accountId"
                    static let category: AccountKeyCategory = .other
                }
            }
            """,
            macros: testMacros
        )
    }

    func testNotMatchingTypes() {
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Account Id", category: .credentials, as: Int.self)
                var accountId: String
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var accountId: String {
                    get {
                        self [__Key_accountId.self]
                    }
                    set {
                        self [__Key_accountId.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "Value type 'Int is expected to match the property binding type annotation 'String'", line: 2, column: 65)
            ],
            macros: testMacros
        )
    }

    func testCustomUI() { // swiftlint:disable:this function_body_length
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(
                    name: "Gender Identity",
                    category: .personalDetails,
                    as: GenderIdentity.self,
                    initial: .default(.preferNotToState),
                    displayView: TestDisplayUI.self,
                    entryView: MyModule.Nested.TestEntryUI.self
                )
                public var genderIdentity: GenderIdentity?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                public var genderIdentity: GenderIdentity? {
                    get {
                        self [__Key_genderIdentity.self]
                    }
                    set {
                        self [__Key_genderIdentity.self] = newValue
                    }
                }

                public struct __Key_genderIdentity: AccountKey {
                    public typealias Value = GenderIdentity
            
                    public static let name: LocalizedStringResource = "Gender Identity"
                    public static let identifier: String = "genderIdentity"
                    public static let category: AccountKeyCategory = .personalDetails
                    public static var initialValue: InitialValue<Value> {
                        .default(.preferNotToState)
                    }
                    public struct DataDisplay: DataDisplayView {
                        private let value: Value

                        public var body: some View {
                            TestDisplayUI(value)
                        }

                        public init(_ value: Value) {
                            self.value = value
                        }
                    }
                    public struct DataEntry: DataEntryView {
                        @Binding private var value: Value

                        public var body: some View {
                            MyModule.Nested.TestEntryUI($value)
                        }

                        public init(_ value: Binding<Value>) {
                            self._value = value
                        }
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testCustomUINameCollision() { // swiftlint:disable:this function_body_length
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(
                    name: "Gender Identity",
                    category: .personalDetails,
                    as: GenderIdentity.self,
                    initial: .default(.preferNotToState),
                    displayView: DataDisplay.self,
                    entryView: DataEntry.self
                )
                var genderIdentity: GenderIdentity?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var genderIdentity: GenderIdentity? {
                    get {
                        self [__Key_genderIdentity.self]
                    }
                    set {
                        self [__Key_genderIdentity.self] = newValue
                    }
                }
            
                struct __Key_genderIdentity: AccountKey {
                    typealias Value = GenderIdentity
            
                    static let name: LocalizedStringResource = "Gender Identity"
                    static let identifier: String = "genderIdentity"
                    static let category: AccountKeyCategory = .personalDetails
                    static var initialValue: InitialValue<Value> {
                        .default(.preferNotToState)
                    }
                    struct DataDisplay: DataDisplayView {
                        private let value: Value
            
                        var body: some View {
                            DataDisplay(value)
                        }
            
                        init(_ value: Value) {
                            self.value = value
                        }
                    }
                    struct DataEntry: DataEntryView {
                        @Binding private var value: Value
            
                        var body: some View {
                            DataEntry($value)
                        }
            
                        init(_ value: Binding<Value>) {
                            self._value = value
                        }
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "The type name 'DataDisplay' is ambiguous. Please disambiguate or rename.", line: 7, column: 22),
                DiagnosticSpec(message: "The type name 'DataEntry' is ambiguous. Please disambiguate or rename.", line: 8, column: 20)
            ],
            macros: testMacros
        )
    }

    func testAccountKeysEntry() {
        assertMacroExpansion(
            """
            @KeyEntry(\\.genderIdentity)
            extension AccountKeys {
            }
            """,
            expandedSource:
            """
            extension AccountKeys {
            
                var genderIdentity: AccountDetails.__Key_genderIdentity.Type {
                    AccountDetails.__Key_genderIdentity.self
                }
            
                static var genderIdentity: AccountDetails.__Key_genderIdentity.Type {
                    AccountDetails.__Key_genderIdentity.self
                }
            }
            """,
            macros: testMacros
        )
    }


    func testGeneralDiagnostics() { // swiftlint:disable:this function_body_length
        assertMacroExpansion(
            """
            @AccountKey(
                name: "Gender Identity",
                category: .personalDetails,
                as: GenderIdentity.self,
                initial: .default(.preferNotToState),
                displayView: DataDisplay.self,
                entryView: DataEntry.self
            )
            extension AccountDetails {
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@AccountKey' can only be applied to a 'var' declaration", line: 1, column: 1)
            ],
            macros: testMacros
        )

        assertMacroExpansion(
            """
            extension NotAccountDetails {
                @AccountKey(
                    name: "Gender Identity",
                    category: .personalDetails,
                    as: GenderIdentity.self,
                    initial: .default(.preferNotToState),
                    displayView: DataDisplay.self,
                    entryView: DataEntry.self
                )
                var genderIdentity: GenderIdentity?
            }
            """,
            expandedSource:
            """
            extension NotAccountDetails {
                var genderIdentity: GenderIdentity? {
                    get {
                        self [__Key_genderIdentity.self]
                    }
                    set {
                        self [__Key_genderIdentity.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@AccountKey' can only be applied to 'var' declarations inside of an extension to 'AccountDetails'",
                    line: 2,
                    column: 5
                )
            ],
            macros: testMacros
        )

        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Gender Identity", category: .personalDetails, as: GenderIdentity.self, initial: .default(.preferNotToState))
                var genderIdentity: GenderIdentity? = .male
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var genderIdentity: GenderIdentity? {
                    get {
                        self [__Key_genderIdentity.self]
                    }
                    set {
                        self [__Key_genderIdentity.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "Variable binding cannot have a initializer", line: 3, column: 41)
            ],
            macros: testMacros
        )
    }
}

#endif
