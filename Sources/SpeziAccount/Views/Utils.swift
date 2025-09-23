//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ProcessInfo {
    static let isIOSAtLeast26 = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
}
