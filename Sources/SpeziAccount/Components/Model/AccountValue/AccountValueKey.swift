//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public protocol AccountValueKey { // TODO this mandates a statically required account value key
    associatedtype Value: Sendable
}

public protocol OptionalAccountValueKey: AccountValueKey {}
