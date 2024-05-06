//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import os
import SwiftUI


// TODO: SpeziViews issue was actually resolved???
struct LoggerKey: EnvironmentKey {
    // this is currently internal to SpeziAccount but will be addressed on a framework level with https://github.com/StanfordSpezi/SpeziViews/issues/9
    static let defaultValue = Logger(subsystem: "edu.stanford.spezi", category: "SpeziAccount")
}


extension EnvironmentValues {
    var logger: Logger {
        get {
            self[LoggerKey.self]
        }
        set {
            self[LoggerKey.self] = newValue
        }
    }
}
