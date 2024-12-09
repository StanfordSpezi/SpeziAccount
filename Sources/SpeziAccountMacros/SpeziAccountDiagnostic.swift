//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftDiagnostics
import SwiftSyntax


struct SpeziAccountDiagnostic: DiagnosticMessage {
    enum ID: String {
        case invalidSyntax = "invalid syntax"
        case invalidApplication = "invalid application"
    }

    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    init(message: String, diagnosticID: MessageID, severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }

    init(message: String, domain: String, id: ID, severity: SwiftDiagnostics.DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: domain, id: id.rawValue)
        self.severity = severity
    }
}


extension Diagnostic {
    init<S: SyntaxProtocol>(
        syntax: S,
        message: String,
        domain: String = "SpeziAccount", // swiftlint:disable:this function_default_parameter_at_end
        id: SpeziAccountDiagnostic.ID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.init(node: Syntax(syntax), message: SpeziAccountDiagnostic(message: message, domain: domain, id: id, severity: severity))
    }
}


extension DiagnosticsError {
    init<S: SyntaxProtocol>(
        syntax: S,
        message: String,
        domain: String = "SpeziAccount", // swiftlint:disable:this function_default_parameter_at_end
        id: SpeziAccountDiagnostic.ID,
        severity: SwiftDiagnostics.DiagnosticSeverity = .error
    ) {
        self.init(diagnostics: [
            Diagnostic(node: Syntax(syntax), message: SpeziAccountDiagnostic(message: message, domain: domain, id: id, severity: severity))
        ])
    }
}
