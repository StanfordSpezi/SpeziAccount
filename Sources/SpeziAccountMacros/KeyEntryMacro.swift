//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftSyntax
import SwiftSyntaxMacros

public struct FreeStandingAccountKeyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first,
              node.arguments.count == 1 else {
            return "" // TODO: diagnostic!
        }

        guard let keyPathExpression = argument.expression.as(KeyPathExprSyntax.self) else {
            return ""
        }

        guard let component = keyPathExpression.components.last,
              keyPathExpression.components.count == 1 else {
            return "" // TODO: check the difference if we provide it by explicit type?
        }

        guard let propertyComponent = component.component.as(KeyPathPropertyComponentSyntax.self) else {
            return ""
        }

        let name = propertyComponent.declName.baseName

        // TODO: code duplication!

        return "AccountDetails.__Key_\(name)"
    }
}


public struct KeyEntryMacro {}


extension KeyEntryMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard case let .argumentList(arguments) = node.arguments,
              let argument = arguments.first,
              arguments.count == 1 else {
            return [] // TODO: diagnostic!
        }

        guard let keyPathExpression = argument.expression.as(KeyPathExprSyntax.self) else {
            return []
        }

        guard let component = keyPathExpression.components.last,
              keyPathExpression.components.count == 1 else {
            return [] // TODO: check the difference if we provide it by explicit type?
        }

        guard let propertyComponent = component.component.as(KeyPathPropertyComponentSyntax.self) else {
            return []
        }

        let name = propertyComponent.declName.baseName

        let variable: DeclSyntax =
        """
        var \(name): AccountDetails.__Key_\(name).Type {
        AccountDetails.__Key_\(name).self
        }
        
        
        """

        let staticVariable: DeclSyntax =
        """
        static var \(name): AccountDetails.__Key_\(name).Type {
        AccountDetails.__Key_\(name).self
        }
        
        
        """

        return [
            variable,
            staticVariable
        ]
    }
}
