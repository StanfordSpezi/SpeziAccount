//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if os(macOS) // macro tests can only be run on the host machine
import SpeziAccountMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

let testMacrosSpecs: [String: MacroSpec] = [
    "AccountKey": MacroSpec(type: AccountKeyMacro.self),
    "KeyEntry": MacroSpec(type: KeyEntryMacro.self)
]

@Suite("AccountKeyMacro Tests")
struct AccountKeyMacroTests { // swiftlint:disable:this type_body_length
    @Test
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
                        self[__Key_genderIdentity.self]
                    }
                    set {
                        self[__Key_genderIdentity.self] = newValue
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
                    static let options: AccountKeyOptions = .default
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
                        self[__Key_genderIdentity.self]
                    }
                    set {
                        self[__Key_genderIdentity.self] = newValue
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
                    static let options: AccountKeyOptions = .default
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
                        self[__Key_genderIdentity.self]
                    }
                    set {
                        self[__Key_genderIdentity.self] = newValue
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
                    public static let options: AccountKeyOptions = .default
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
                        self[__Key_accountId.self]
                    }
                    set {
                        self[__Key_accountId.self] = newValue
                    }
                }
            
                struct __Key_accountId: RequiredAccountKey {
                    typealias Value = String
            
                    static let name: LocalizedStringResource = "Account Id"
                    static let identifier: String = "accountId"
                    static let category: AccountKeyCategory = .other
                    static let options: AccountKeyOptions = .default
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
                        self[__Key_accountId.self]
                    }
                    set {
                        self[__Key_accountId.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "Value type 'Int is expected to match the property binding type annotation 'String'", line: 2, column: 65)
            ],
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
                        self[__Key_genderIdentity.self]
                    }
                    set {
                        self[__Key_genderIdentity.self] = newValue
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
                    public static let options: AccountKeyOptions = .default
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
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
                        self[__Key_genderIdentity.self]
                    }
                    set {
                        self[__Key_genderIdentity.self] = newValue
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
                    static let options: AccountKeyOptions = .default
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
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
    func testAccountKeyOptions() { // swiftlint:disable:this function_body_length
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Name", options: .default, as: String.self, initial: .default("Hello World"))
                var name: String?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var name: String? {
                    get {
                        self[__Key_name.self]
                    }
                    set {
                        self[__Key_name.self] = newValue
                    }
                }
            
                struct __Key_name: AccountKey {
                    typealias Value = String
            
                    static let name: LocalizedStringResource = "Name"
                    static let identifier: String = "name"
                    static let category: AccountKeyCategory = .other
                    static var initialValue: InitialValue<Value> {
                        .default("Hello World")
                    }
                    static let options: AccountKeyOptions = .default
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )

        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Name", options: [.display, .mutable], as: String.self, initial: .default("Hello World"))
                var name: String?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var name: String? {
                    get {
                        self[__Key_name.self]
                    }
                    set {
                        self[__Key_name.self] = newValue
                    }
                }
            
                struct __Key_name: AccountKey {
                    typealias Value = String
            
                    static let name: LocalizedStringResource = "Name"
                    static let identifier: String = "name"
                    static let category: AccountKeyCategory = .other
                    static var initialValue: InitialValue<Value> {
                        .default("Hello World")
                    }
                    static let options: AccountKeyOptions = [.display, .mutable]
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )

        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Name", options: [.display], as: String.self, initial: .default("Hello World"))
                var name: String?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var name: String? {
                    get {
                        self[__Key_name.self]
                    }
                    set {
                        self[__Key_name.self] = newValue
                    }
                }
            
                struct __Key_name: AccountKey {
                    typealias Value = String
            
                    static let name: LocalizedStringResource = "Name"
                    static let identifier: String = "name"
                    static let category: AccountKeyCategory = .other
                    static var initialValue: InitialValue<Value> {
                        .default("Hello World")
                    }
                    static let options: AccountKeyOptions = [.display]
                    struct DataEntry: DataEntryView {
                        var body: some View {
                            fatalError("'\\("Name")' does not support mutable access.")
                        }
            
                        init(_ value: Binding<Value>) {
                            fatalError("'\\("Name")' does not support mutable access.")
                        }
                    }
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )

        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Name", options: .mutable, as: String.self, initial: .default("Hello World"))
                var name: String?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var name: String? {
                    get {
                        self[__Key_name.self]
                    }
                    set {
                        self[__Key_name.self] = newValue
                    }
                }
            
                struct __Key_name: AccountKey {
                    typealias Value = String
            
                    static let name: LocalizedStringResource = "Name"
                    static let identifier: String = "name"
                    static let category: AccountKeyCategory = .other
                    static var initialValue: InitialValue<Value> {
                        .default("Hello World")
                    }
                    static let options: AccountKeyOptions = .mutable
                    struct DataDisplay: DataDisplayView {
                        var body: some View {
                            fatalError("'\\("Name")' does not support display access.")
                        }
            
                        init(_ value: Value) {
                            fatalError("'\\("Name")' does not support display access.")
                        }
                    }
                    struct DataEntry: DataEntryView {
                        var body: some View {
                            fatalError("'\\("Name")' does not support display access.")
                        }
            
                        init(_ value: Binding<Value>) {
                            fatalError("'\\("Name")' does not support display access.")
                        }
                    }
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
    func testAccountKeyOptionsDiagnostics() { // swiftlint:disable:this function_body_length
        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Name", options: [.display], as: String.self, initial: .default("Hello World"), entryView: CustomView.self)
                var name: String?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var name: String? {
                    get {
                        self[__Key_name.self]
                    }
                    set {
                        self[__Key_name.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Cannot provide a `entryView` if the `@AccountKey` does not specify `display` and `mutable` option.",
                    line: 2,
                    column: 31
                )
            ],
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )

        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Name", options: [.mutable], as: String.self, initial: .default("Hello World"), displayView: CustomView.self)
                var name: String?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var name: String? {
                    get {
                        self[__Key_name.self]
                    }
                    set {
                        self[__Key_name.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Cannot provide a `displayView` if the `@AccountKey` does not specify `display` option.",
                    line: 2,
                    column: 31
                )
            ],
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )

        assertMacroExpansion(
            """
            extension AccountDetails {
                @AccountKey(name: "Name", options: [.mutable], as: String.self, initial: .default("Hello World"), entryView: CustomView.self)
                var name: String?
            }
            """,
            expandedSource:
            """
            extension AccountDetails {
                var name: String? {
                    get {
                        self[__Key_name.self]
                    }
                    set {
                        self[__Key_name.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Cannot provide a `entryView` if the `@AccountKey` does not specify `display` and `mutable` option.",
                    line: 2,
                    column: 31
                )
            ],
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    @Test
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
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
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
                        self[__Key_genderIdentity.self]
                    }
                    set {
                        self[__Key_genderIdentity.self] = newValue
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
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
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
                        self[__Key_genderIdentity.self]
                    }
                    set {
                        self[__Key_genderIdentity.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "Variable binding cannot have a initializer", line: 3, column: 41)
            ],
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }
}

#endif

// swiftlint:disable:this file_length
