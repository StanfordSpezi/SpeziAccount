//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


// TODO document which environmnet keys and objects one can expect to be injected!
public protocol DataEntryView<Key>: View {
    associatedtype Key: AccountValueKey

    init(_ value: Binding<Key.Value>)
}
