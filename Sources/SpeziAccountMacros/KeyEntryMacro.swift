//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros


/// The `@KeyEntry` macro.
public struct KeyEntryMacro {}


extension KeyEntryMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard case let .argumentList(arguments) = node.arguments else {
            throw DiagnosticsError(syntax: node, message: "Unexpected arguments passed to '@KeyEntry'", id: .invalidSyntax)
        }

        var result: [DeclSyntax] = []
        result.reserveCapacity(arguments.count * 2)

        for argument in arguments {
            guard let keyPathExpression = argument.expression.as(KeyPathExprSyntax.self),
                  let component = keyPathExpression.components.last,
                  keyPathExpression.components.count == 1,
                  let propertyComponent = component.component.as(KeyPathPropertyComponentSyntax.self) else {
                throw DiagnosticsError(
                    syntax: argument.expression,
                    message: "'@KeyEntry' failed to parse the KeyPath expression in argument 'key'",
                    id: .invalidSyntax
                )
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

            result.append(variable)
            result.append(staticVariable)
        }

        return result
    }
}
