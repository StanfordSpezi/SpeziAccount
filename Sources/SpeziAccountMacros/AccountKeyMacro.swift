//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros


private struct AccountKeyOption: RawRepresentable, Hashable {
    static let display = AccountKeyOption(rawValue: "display")
    static let mutable = AccountKeyOption(rawValue: "mutable")

    static let `default` = AccountKeyOption(rawValue: "default") // special case

    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}


/// The `@AccountKey` macro.
public struct AccountKeyMacro {}


extension AccountKeyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let binding = variableDeclaration.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return [] // diagnostic is provided by the peer macro expansion
        }

        let getAccessor: AccessorDeclSyntax =
        """
        get {
        self[__Key_\(identifier).self]
        }
        """

        let setAccessor: AccessorDeclSyntax =
        """
        set {
        self[__Key_\(identifier).self] = newValue
        }
        """
        return [getAccessor, setAccessor]
    }
}


extension AccountKeyMacro: PeerMacro {
    public static func expansion( // swiftlint:disable:this function_body_length cyclomatic_complexity
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self) else {
            throw DiagnosticsError(syntax: declaration, message: "'@AccountKey' can only be applied to a 'var' declaration", id: .invalidSyntax)
        }

        guard let binding = variableDeclaration.bindings.first,
              variableDeclaration.bindings.count == 1 else {
            throw DiagnosticsError(
                syntax: declaration,
                message: "'@AccountKey' can only be applied to a 'var' declaration with a single binding",
                id: .invalidSyntax
            )
        }

        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw DiagnosticsError(
                syntax: declaration,
                message: "'@AccountKey' can only be applied to a 'var' declaration with a simple name",
                id: .invalidSyntax
            )
        }

        // with previous compilers the `lexicalContext` is empty
        guard let rootContext = context.lexicalContext.first,
              let extensionDecl = rootContext.as(ExtensionDeclSyntax.self),
              let extendedTypeIdentifier = extensionDecl.extendedType.as(IdentifierTypeSyntax.self),
              let extensionIdentifier = extendedTypeIdentifier.name.identifier,
              extensionIdentifier.name == "AccountDetails" else {
            throw DiagnosticsError(
                syntax: declaration,
                message: "'@AccountKey' can only be applied to 'var' declarations inside of an extension to 'AccountDetails'",
                id: .invalidSyntax
            )
        }

        guard let typeAnnotation = binding.typeAnnotation else {
            throw DiagnosticsError(syntax: binding, message: "Variable binding is missing a type annotation", id: .invalidSyntax)
        }

        if let initializer = binding.initializer {
            throw DiagnosticsError(syntax: initializer, message: "Variable binding cannot have a initializer", id: .invalidSyntax)
        }

        guard case let .argumentList(argumentList) = node.arguments else {
            throw DiagnosticsError(syntax: node, message: "Unexpected arguments passed to '@AccountKey'", id: .invalidSyntax)
        }

        guard let name = argumentList.first(where: { $0.label?.text == "name" }) else {
            throw DiagnosticsError(syntax: argumentList, message: "'@AccountKey' is missing required argument 'name'", id: .invalidSyntax)
        }

        guard let valueType = argumentList.first(where: { $0.label?.text == "as" }) else {
            throw DiagnosticsError(syntax: argumentList, message: "'@AccountKey' is missing required argument 'as'", id: .invalidSyntax)
        }

        // optional arguments
        let storageIdentifier = argumentList.first(where: { $0.label?.text == "id" })
        let category = argumentList.first(where: { $0.label?.text == "category" })
        let options = argumentList.first(where: { $0.label?.text == "options" })
        let initial = argumentList.first { $0.label?.text == "initial" }
        let displayViewType = argumentList.first { $0.label?.text == "displayView" }
        let entryView = argumentList.first { $0.label?.text == "entryView" }

        let valueTypeName = try valueType.metaTypeTypeNameArgument(name: "as")
        let displayViewTypeName = try displayViewType?.metaTypeTypeNameArgument(name: "displayView")
        let entryViewTypeName = try entryView?.metaTypeTypeNameArgument(name: "entryView")


        let valueTypeInitializer: TypeSyntax
        let accountKeyProtocol: TokenSyntax

        if let optionalType = typeAnnotation.type.as(OptionalTypeSyntax.self) {
            valueTypeInitializer = optionalType.wrappedType
            accountKeyProtocol = "AccountKey"
        } else {
            valueTypeInitializer = typeAnnotation.type
            accountKeyProtocol = "RequiredAccountKey"
        }

        guard valueTypeInitializer.as(IdentifierTypeSyntax.self)?.name.text == valueTypeName.forceToText else {
            throw DiagnosticsError(
                syntax: valueTypeName,
                message: "Value type '\(valueTypeName) is expected to match the property binding type annotation '\(valueTypeInitializer.as(IdentifierTypeSyntax.self)?.name.text ?? "<<unknown>>")'",
                id: .invalidApplication
            )
        }


        let accountKeyOptions: Set<AccountKeyOption>
        if let options {
            accountKeyOptions = options.expression.accountKeyOptions

            if displayViewTypeName != nil && !accountKeyOptions.contains(.display) {
                throw DiagnosticsError(
                    syntax: options,
                    message: "Cannot provide a `displayView` if the `@AccountKey` does not specify `display` option.",
                    id: .invalidApplication
                )
            }

            if entryViewTypeName != nil && !accountKeyOptions.contains([.display, .mutable]) {
                throw DiagnosticsError(
                    syntax: options,
                    message: "Cannot provide a `entryView` if the `@AccountKey` does not specify `display` and `mutable` option.",
                    id: .invalidApplication
                )
            }
        } else {
            accountKeyOptions = [.display, .mutable]
        }


        let modifier: TokenSyntax? = variableDeclaration.modifiers
            .compactMap { (modifier: DeclModifierSyntax) -> TokenSyntax? in
                guard case let .keyword(keyword) = modifier.name.tokenKind else {
                    return nil
                }

                switch keyword {
                case .internal, .private, .fileprivate, .public:
                    return .keyword(keyword)
                default:
                    return nil
                }
            }
            .first // there is only ever one

        let rawModifier = modifier.map { $0.text + " " } ?? ""

        let key = StructDeclSyntax(
            modifiers: modifier.map { [DeclModifierSyntax(name: $0)] } ?? [],
            name: "__Key_\(identifier)",
            inheritanceClause: InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: accountKeyProtocol))
            })
        ) { // swiftlint:disable:this closure_body_length
            TypeAliasDeclSyntax(
                modifiers: modifier.map { [DeclModifierSyntax(name: $0)] } ?? [],
                name: "Value",
                initializer: TypeInitializerClauseSyntax(value: valueTypeInitializer),
                trailingTrivia: .newlines(2)
            )

            """
            \(raw: rawModifier)static let name: LocalizedStringResource = \(name.expression)
            """

            if let id = storageIdentifier?.expression {
                """
                \(raw: rawModifier)static let identifier: String = \(id)
                """
            } else {
                """
                \(raw: rawModifier)static let identifier: String = "\(identifier)"
                """
            }


            let categoryExpr = category?.expression ?? ExprSyntax(MemberAccessExprSyntax(declName: .init(baseName: .identifier("other"))))
            """
            \(raw: rawModifier)static let category: AccountKeyCategory = \(categoryExpr)
            """

            if let initial {
                """
                \(raw: rawModifier)static var initialValue: InitialValue<Value> {
                \(initial.expression)
                }
                """
            }

            let optionsExpr = options?.expression ?? ExprSyntax(MemberAccessExprSyntax(declName: .init(baseName: .identifier("default"))))
            """
            \(raw: rawModifier)static let options: AccountKeyOptions = \(optionsExpr)
            """

            if let displayViewTypeName {
                """
                \(raw: rawModifier)struct DataDisplay: DataDisplayView {
                    private let value: Value
                    
                    \(raw: rawModifier)var body: some View {
                        \(displayViewTypeName)(value)
                    }
                
                    \(raw: rawModifier)init(_ value: Value) {
                        self.value = value
                    }
                }
                """
            } else if !accountKeyOptions.contains(.display) {
                """
                \(raw: rawModifier)struct DataDisplay: DataDisplayView {
                    \(raw: rawModifier)var body: some View {
                        fatalError("'\\(\(name.expression))' does not support display access.")
                    }
                
                    \(raw: rawModifier)init(_ value: Value) {
                        fatalError("'\\(\(name.expression))' does not support display access.")
                    }
                }
                """
            }

            if let entryViewTypeName {
                """
                \(raw: rawModifier)struct DataEntry: DataEntryView {
                    @Binding private var value: Value
                    
                    \(raw: rawModifier)var body: some View {
                        \(entryViewTypeName)($value)
                    }
                
                    \(raw: rawModifier)init(_ value: Binding<Value>) {
                        self._value = value
                    }
                }
                """
            } else if !accountKeyOptions.contains(.mutable) {
                """
                \(raw: rawModifier)struct DataEntry: DataEntryView {
                    \(raw: rawModifier)var body: some View {
                        fatalError("'\\(\(name.expression))' does not support mutable access.")
                    }
                
                    \(raw: rawModifier)init(_ value: Binding<Value>) {
                        fatalError("'\\(\(name.expression))' does not support mutable access.")
                    }
                }
                """
            } else if !accountKeyOptions.contains(.display) {
                """
                \(raw: rawModifier)struct DataEntry: DataEntryView {
                    \(raw: rawModifier)var body: some View {
                        fatalError("'\\(\(name.expression))' does not support display access.")
                    }
                
                    \(raw: rawModifier)init(_ value: Binding<Value>) {
                        fatalError("'\\(\(name.expression))' does not support display access.")
                    }
                }
                """
            }
        }

        if let displayViewTypeName, displayViewTypeName.forceToText == "DataDisplay" {
            context.diagnose(Diagnostic(
                syntax: displayViewTypeName,
                message: "The type name '\(displayViewTypeName)' is ambiguous. Please disambiguate or rename.",
                id: .invalidApplication
            ))
        }
        if let entryViewTypeName, entryViewTypeName.forceToText == "DataEntry" {
            context.diagnose(Diagnostic(
                syntax: entryViewTypeName,
                message: "The type name '\(entryViewTypeName)' is ambiguous. Please disambiguate or rename.",
                id: .invalidApplication
            ))
        }

        return [
            DeclSyntax(key)
        ]
    }
}


extension LabeledExprSyntax {
    func metaTypeTypeNameArgument(name: String) throws -> any ExprSyntaxProtocol {
        guard let valueTypeExpression = expression.as(MemberAccessExprSyntax.self),
              valueTypeExpression.declName.baseName.tokenKind == .keyword(.`self`),
              let base = valueTypeExpression.base else {
            throw DiagnosticsError(syntax: self, message: "'@AccountKey' failed to parse the meta type expression in argument '\(name)'", id: .invalidSyntax)
        }

        if let nestedMemberAccess = base.as(MemberAccessExprSyntax.self) {
            return nestedMemberAccess
        } else if let valueTypeName = base.as(DeclReferenceExprSyntax.self) {
            return valueTypeName
        } else {
            throw DiagnosticsError(syntax: self, message: "'@AccountKey' failed to parse the meta type expression in argument '\(name)'", id: .invalidSyntax)
        }
    }
}


extension ExprSyntaxProtocol {
    var forceToText: String {
        String(decoding: syntaxTextBytes, as: UTF8.self)
    }
}


extension ExprSyntax {
    fileprivate var accountKeyOptions: Set<AccountKeyOption> {
        /*
         We cover either of these two cases where `expression` is this `ExprSyntax` node.

         ├─expression: MemberAccessExprSyntax
         │ ├─period: period
         │ ╰─declName: DeclReferenceExprSyntax
         │   ╰─baseName: identifier("default")

         ├─expression: ArrayExprSyntax
         │ ├─leftSquare: leftSquare
         │ ├─elements: ArrayElementListSyntax
         │ │ ├─[0]: ArrayElementSyntax
         │ │ │ ├─expression: MemberAccessExprSyntax
         │ │ │ │ ├─period: period
         │ │ │ │ ╰─declName: DeclReferenceExprSyntax
         │ │ │ │   ╰─baseName: identifier("read")
         │ │ │ ╰─trailingComma: comma
         │ │ ╰─[1]: ArrayElementSyntax
         │ │   ╰─expression: MemberAccessExprSyntax
         │ │     ├─period: period
         │ │     ╰─declName: DeclReferenceExprSyntax
         │ │       ╰─baseName: identifier("mutable")
         │ ╰─rightSquare: rightSquare
         */
        var options: Set<AccountKeyOption>
        if let memberAccess = self.as(MemberAccessExprSyntax.self) {
            options = [AccountKeyOption(rawValue: memberAccess.declName.forceToText)]
        } else if let array = self.as(ArrayExprSyntax.self) {
            options = Set(array.elements.compactMap { arrayElement in
                guard let memberAccess = arrayElement.expression.as(MemberAccessExprSyntax.self) else {
                    return nil
                }

                return AccountKeyOption(rawValue: memberAccess.declName.forceToText)
            })
        } else {
            return []
        }

        if options.contains(.default) {
            options.remove(.default)
            options.formUnion([.display, .mutable])
        }

        return options
    }
}
