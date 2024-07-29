//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


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
                @AccountKey(name: "Gender Identity", category: .personalDetails, initial: .default(GenderIdentity.preferNotToState))
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
                        .default(GenderIdentity.preferNotToState)
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
                @AccountKey(name: "Gender Identity", category: .personalDetails, initial: .default(GenderIdentity.preferNotToState))
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
                        .default(GenderIdentity.preferNotToState)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testRequiredAccountKey() {
        assertMacroExpansion( // TODO: test with leaving out initial!
            """
            extension AccountDetails {
                @AccountKey(name: "Account Id", category: .credentials, initial: .empty(""))
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
                    static var initialValue: InitialValue<Value> {
                        .empty("")
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
            }
            """,
            macros: testMacros
        )
    }

    func testFreestandingAccountKey() {
        assertMacroExpansion(
            """
            #AccountKey(\\.genderIdentity)
            """,
            expandedSource:
            """
            AccountDetails.__Key_genderIdentity
            """,
            macros: [
                "AccountKey": FreeStandingAccountKeyMacro.self
            ]
        )
    }
}
