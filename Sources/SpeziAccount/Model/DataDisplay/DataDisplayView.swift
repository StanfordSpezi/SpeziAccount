//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


public protocol DataDisplayView<Key>: View { // TODO rename to row!(?)
    associatedtype Key: AccountValueKey

    init(_ value: Key.Value)
}
