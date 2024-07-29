//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftSyntax
import SwiftSyntaxMacros


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
            throw AccountKeyMacroError.argumentListInconsistency
        }

        guard let keyPathExpression = argument.expression.as(KeyPathExprSyntax.self),
              let component = keyPathExpression.components.last,
              keyPathExpression.components.count == 1,
              let propertyComponent = component.component.as(KeyPathPropertyComponentSyntax.self) else {
            throw AccountKeyMacroError.failedKeyPathParsing
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
