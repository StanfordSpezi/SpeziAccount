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
            throw DiagnosticsError(syntax: declaration, message: "'@AccountKey' was unable to determine the property name", id: .invalidSyntax)
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
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let binding = variableDeclaration.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw DiagnosticsError(syntax: declaration, message: "'@AccountKey' was unable to determine the property name", id: .invalidSyntax)
        }

        guard let typeAnnotation = binding.typeAnnotation else {
            throw DiagnosticsError(syntax: binding, message: "Variable binding is missing the type annotation", id: .invalidSyntax)
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


        let modifier: TokenSyntax? = variableDeclaration.modifiers
            .compactMap { modifier in
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
    var forceToText: String? {
        String(data: Data(syntaxTextBytes), encoding: .utf8)
    }
}
