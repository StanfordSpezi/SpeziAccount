//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// TODO list bundeled ones!
public protocol AccountValueKey { // TODO docs: requirement is static => be sure when you define a required one! most likely an Optional one!
    associatedtype Value: Sendable
}

public protocol OptionalAccountValueKey: AccountValueKey {}
