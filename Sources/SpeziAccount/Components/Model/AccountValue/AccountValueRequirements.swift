//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

private enum RequirementType {
    /// The respective AccountValue MUST be provided by the user.
    case required
    /// The respective AccountValue CAN be provided by the user but there is no obligation to do so.
    case displayed
}

private protocol AnyRequirement {
    var type: RequirementType { get }

    func hasValue(in storage: AccountValueStorage) -> Bool
}

private struct Requirement<Key: AccountValueKey>: AnyRequirement {
    let type: RequirementType

    func hasValue(in storage: AccountValueStorage) -> Bool {
        // TODO how to check the value without throwing?
        return true
    }
}

public struct AccountValueRequirements {
    private var requirements: [ObjectIdentifier: AnyRequirement] = [:]

    public init() {}

    // TODO how to build?

    private func requirementType<Key: AccountValueKey>(for key: Key.Type) -> RequirementType? {
        requirements[ObjectIdentifier(key)]?.type
    }

    public func configured<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        requirementType(for: key) != nil
    }

    public func required<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        requirementType(for: key) == .required
    }

    public func validateRequirements(in storage: AccountValueStorage) {
        for requirement in requirements.values where requirement.type == .required {
            if !requirement.hasValue(in: storage) {
                fatalError("Failed to have value in storage!")
                // TODO get the name to throw!
                // TODO make the error
            }
        }
    }
}
