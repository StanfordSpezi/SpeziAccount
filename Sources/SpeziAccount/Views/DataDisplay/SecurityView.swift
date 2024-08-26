//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public protocol SecurityView: DataDisplayView { // TODO: this is not special to security!
    @MainActor
    init()
}


extension SecurityView {
    @MainActor
    public init(_ value: Value) {
        self.init()
    }
}
