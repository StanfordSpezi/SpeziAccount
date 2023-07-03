//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum KeyType {
    /// The respective AccountValue MUST be provided by the user.
    case required
    /// The respective AccountValue CAN be provided by the user but there is no obligation to do so.
    case optional
}

@resultBuilder
public enum AccountValueRequirementsBuilder {
    public static func buildExpression<Key: AccountValueKey>(_ expression: Key.Type) -> [AnyRequirement] {
        [Requirement<Key>(type: .required)] // TODO pass something else!
    }

    public static func buildExpression<Key: OptionalAccountValueKey>(_ expression: Key.Type) -> [AnyRequirement] {
        [Requirement<Key>(type: .optional)] // TODO pass something else!
    }

    public static func buildBlock(_ components: [AnyRequirement]...) -> [AnyRequirement] {
        var result: [AnyRequirement] = []
        for componentArray in components {
            result.append(contentsOf: componentArray)
        }
        return result
    }

    // TODO support conditionals, optionals and whatever!
}

public protocol AnyRequirement  {
    var type: KeyType { get }
    var id: ObjectIdentifier { get }

    func hasValue(in storage: AccountValueStorage) -> Bool
}

private struct Requirement<Key: AccountValueKey>: AnyRequirement {
    let type: KeyType
    var id: ObjectIdentifier {
        ObjectIdentifier(Key.self)
    }

    public init(type: KeyType) {
        self.type = type
    }

    func hasValue(in storage: AccountValueStorage) -> Bool {
        // TODO how to check the value without throwing?
        return true
    }
}

public struct AccountValueRequirements {
    public static var `default` = AccountValueRequirements {
        UserIdAccountValueKey.self
        PasswordAccountValueKey.self
        NameAccountValueKey.self
        GenderIdentityAccountValueKey.self
        DateOfBirthAccountValueKey.self
    }

    private var requirements: [ObjectIdentifier: AnyRequirement] = [:]

    public init() {}

    public init(@AccountValueRequirementsBuilder _ requirements: () -> [AnyRequirement]) {
        self.requirements = [:]

        for requirement in requirements() {
            self.requirements[requirement.id] = requirement
        }
    }

    private func requirementType<Key: AccountValueKey>(for key: Key.Type) -> KeyType? {
        requirements[ObjectIdentifier(key)]?.type
    }

    public func configured<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        requirementType(for: key) != nil
    }

    // TODO query multiple? (paramter packs?)

    public func required<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        requirementType(for: key) == .required
    }

    public func validateRequirements(in storage: SignupRequest) {
        for requirement in requirements.values where requirement.type == .required {
            if !requirement.hasValue(in: storage.storage) {
                fatalError("Failed to have value in storage!")
                // TODO get the name to throw!
                // TODO make the error
            }
        }
    }
}
