//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros


@main
struct SpeziAccountMacros: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [
        AccountKeyMacro.self,
        KeyEntryMacro.self,
        FreeStandingAccountKeyMacro.self
    ]
}
