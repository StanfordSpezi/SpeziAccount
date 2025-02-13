//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

// Adapted function from https://github.com/swiftlang/swift-syntax/blob/main/Sources/SwiftSyntaxMacrosTestSupport/Assertions.swift
func assertMacroExpansionWithSwiftTesting(
  _ originalSource: String,
  expandedSource expectedExpandedSource: String,
  // swiftlint:disable:next function_default_parameter_at_end
  diagnostics: [DiagnosticSpec] = [],
  macros: [String: Macro.Type],
  applyFixIts: [String] = [],
  fixedSource expectedFixedSource: String? = nil,
  testModuleName: String = "TestModule",
  testFileName: String = "test.swift",
  indentationWidth: Trivia = .spaces(4),
  file: StaticString = #filePath,
  line: UInt = #line,
  sourceLocation: Testing.SourceLocation = #_sourceLocation
) {
  let specs = macros.mapValues { MacroSpec(type: $0) }
  assertMacroExpansion(
    originalSource,
    expandedSource: expectedExpandedSource,
    diagnostics: diagnostics,
    macroSpecs: specs,
    applyFixIts: applyFixIts,
    fixedSource: expectedFixedSource,
    testModuleName: testModuleName,
    testFileName: testFileName,
    indentationWidth: indentationWidth,
    failureHandler: { Issue.record("\($0.message)", sourceLocation: sourceLocation) }
  )
}
