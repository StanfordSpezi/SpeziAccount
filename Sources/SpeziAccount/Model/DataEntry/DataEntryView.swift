//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


public protocol DataEntryView<Key>: View {
    associatedtype Key: AccountValueKey

    init(_ value: Binding<Key.Value>)

    func onDataSubmission() -> DataValidationResult
}

extension DataEntryView {
    public func onDataSubmission() -> DataValidationResult {
        .success
    }
}
