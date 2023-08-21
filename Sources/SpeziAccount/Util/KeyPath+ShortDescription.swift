//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension KeyPath {
    var shortDescription: String {
        if #available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *) {
            // see https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
            var description = self.debugDescription
            if let slash = description.firstIndex(of: "\\"), let dot = description.firstIndex(of: ".") {
                description.removeSubrange(description.index(after: slash) ..< dot)
            }
            return description
        } else {
            // it's an okay fallback
            return "\(Value.self)"
        }
    }
}
