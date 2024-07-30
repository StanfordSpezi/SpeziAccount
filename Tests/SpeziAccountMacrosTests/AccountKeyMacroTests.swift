//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if os(macOS) // macro tests can only be run on the host machine

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SpeziAccountMacros

let testMacros: [String: any Macro.Type] = [
    "AccountKey": AccountKeyMacro.self,
    "KeyEntry": KeyEntryMacro.self
]


final class AccountKeyMacroTests: XCTestCase {
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
                @AccountKey(name: "Account Id", category: .credentials, as: String.self)
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
                    static let category: AccountKeyCategory = .credentials
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
                DiagnosticSpec(message: "Argument type 'Int' did not match expected variable type 'String'", line: 2, column: 5)
            ],
            macros: testMacros
        )
    }

    func testCustomUI() { // TODO: test collision of DataEntry and DataDisplay
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
                var genderIdentity: GenderIdentity?
            }
            """,
            expandedSource: // TODO: maybe test with public modifiers?
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
                    static let category: AccountKeyCategory = .personalDetails
                    static var initialValue: InitialValue<Value> {
                        .default(.preferNotToState)
                    }
                    struct DataDisplay: DataDisplayView {
                        private let value: Value

                        var body: some View {
                            TestDisplayUI(value)
                        }

                        init(_ value: Value) {
                            self.value = value
                        }
                    }
                    struct DataEntry: DataEntryView {
                        @Binding private var value: Value

                        var body: some View {
                            MyModule.Nested.TestEntryUI($value)
                        }

                        init(_ value: Binding<Value>) {
                            self._value = value
                        }
                    }
                }
            }
            """,
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
}

#endif
