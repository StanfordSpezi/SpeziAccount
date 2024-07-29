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
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let binding = variableDeclaration.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw AccountKeyMacroError.couldNotDetermineIdentifier
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
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let binding = variableDeclaration.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw AccountKeyMacroError.couldNotDetermineIdentifier
        }

        guard case let .argumentList(argumentList) = node.arguments,
              let name = argumentList.first(where: { $0.label?.text == "name" }),
              let category = argumentList.first(where: { $0.label?.text == "category" }),
              let valueType = argumentList.first(where: { $0.label?.text == "as" }) else {
            throw AccountKeyMacroError.argumentListInconsistency
        }

        guard let typeAnnotation = binding.typeAnnotation else {
            throw AccountKeyMacroError.propertyIsMissingTypeAnnotation
        }


        let valueTypeInitializer: TypeSyntax
        let accountKeyProtocol: TokenSyntax

        if let optionalType = typeAnnotation.type.as(OptionalTypeSyntax.self) {
            valueTypeInitializer = optionalType.wrappedType
            accountKeyProtocol = "AccountKey"
        } else {
            valueTypeInitializer = typeAnnotation.type
            accountKeyProtocol = "RequiredAccountKey"
        }

        guard let valueTypeExpression = valueType.expression.as(MemberAccessExprSyntax.self),
              valueTypeExpression.declName.baseName.tokenKind == .keyword(.`self`),
              let valueTypeName = valueTypeExpression.base?.as(DeclReferenceExprSyntax.self)?.baseName else {
            throw AccountKeyMacroError.unableToDetermineValueArgument
        }

        guard valueTypeInitializer.as(IdentifierTypeSyntax.self)?.name.text == valueTypeName.text else {
            throw AccountKeyMacroError.typesNotMatching(
                argument: valueTypeName.text,
                variable: valueTypeInitializer.as(IdentifierTypeSyntax.self)?.name.text ?? "<<unknown>>"
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
        ) {
            TypeAliasDeclSyntax(
                modifiers: modifier.map { [DeclModifierSyntax(name: $0)] } ?? [],
                name: "Value",
                initializer: TypeInitializerClauseSyntax(value: valueTypeInitializer),
                trailingTrivia: .newlines(2)
            )

            """
            \(raw: rawModifier)static let name: LocalizedStringResource = \(name.expression)
            """

            """
            \(raw: rawModifier)static let category: AccountKeyCategory = \(category.expression)
            """

            if let initial = argumentList.first(where: { $0.label?.text == "initial" }) {
                """
                \(raw: rawModifier)static var initialValue: InitialValue<Value> {
                \(initial.expression)
                }
                """
            }
        }

        return [
            DeclSyntax(key)
        ]
    }
}
