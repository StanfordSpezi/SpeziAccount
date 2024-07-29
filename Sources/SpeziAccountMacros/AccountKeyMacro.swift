//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftSyntax
import SwiftSyntaxMacros


public struct AccountKeyMacro {}


extension AccountKeyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self) else {
            return [] // TODO: todo!
        }

        guard let binding = variableDeclaration.bindings.first else {
            return [] // TODO: multiple bindings?
        }

        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return []
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
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // TODO: check that the macro is only used in AccountKeys extensions?

        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self) else {
            return [] // TODO: todo!
        }

        guard case let .argumentList(argumentList) = node.arguments else {
            return [] // TODO: error!
        }

        // TODO: best way to retrieve arguments?
        guard let name = argumentList.first(where: { $0.label?.text == "name" }), // TODO: e.g., StringLiteralExprSyntax
              let category = argumentList.first(where: { $0.label?.text == "category" }), // TODO: MemberAccessExprSyntax
              // let valueType = argumentList.first(where: { $0.label?.text == "as" }), // TODO: MemberAccessExprSyntax
              let initial = argumentList.first(where: { $0.label?.text == "initial" }) else {
            return [] // TODO: error
        }
/*
        guard let valueTypeExpression = valueType.expression.as(MemberAccessExprSyntax.self) else {
            return []
        }
        */

        guard let binding = variableDeclaration.bindings.first else {
            return [] // TODO: multiple bindings?
        }

        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return []
        }

        guard let typeAnnotation = binding.typeAnnotation else {
            // TODO: import SwiftDiagnostics
            return [] // TODO: we require a type annoitation
        }


        let valueType: TypeSyntax
        let accountKeyProtocol: TokenSyntax

        if let optionalType = typeAnnotation.type.as(OptionalTypeSyntax.self) {
            valueType = optionalType.wrappedType
            accountKeyProtocol = "AccountKey"
        } else { // TODO: double check the whatever!
            valueType = typeAnnotation.type
            accountKeyProtocol = "RequiredAccountKey"
        }

        /*
        guard valueTypeExpression.declName.baseName.tokenKind == .keyword(.`self`) else {
            return [] // TODO: error!
        }

        guard let baseExpr = valueTypeExpression.base?.as(DeclReferenceExprSyntax.self)?.baseName else {
            return []
        }

        let swiftValueType = valueTypeExpression.base
*/
        // TODO: also support private? filepirvate etc?
        var isPublic = variableDeclaration.modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.public)
        }

        let key = StructDeclSyntax(
            modifiers: isPublic
                ? [
                    DeclModifierSyntax(name: .keyword(.public))
                ]
                : [],
            name: "__Key_\(identifier)",
            inheritanceClause: InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: accountKeyProtocol))
            })
        ) {
            TypeAliasDeclSyntax(
                modifiers: isPublic
                ? [
                    DeclModifierSyntax(name: .keyword(.public))
                ]
                : [],
                name: "Value",
                initializer: TypeInitializerClauseSyntax(value: valueType),
                trailingTrivia: .newlines(2)
            )

            """
            \(raw: isPublic ? "public " : "")static let name: LocalizedStringResource = \(name.expression)
            \(raw: isPublic ? "public " : "")static let category: AccountKeyCategory = \(category.expression)
            \(raw: isPublic ? "public " : "")static var initialValue: InitialValue<Value> {
            \(initial.expression)
            }
            """
        }

        return [
            DeclSyntax(key)
        ]
    }
}
