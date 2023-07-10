//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public struct AccountValueRequirements {
    public static var `default` = AccountValueRequirements {
        UserIdAccountValueKey.self
        PasswordAccountValueKey.self
        NameAccountValueKey.self
        GenderIdentityAccountValueKey.self
        DateOfBirthAccountValueKey.self
    }

    private var requirements: [ObjectIdentifier: AnyAccountValueRequirement] = [:]

    public init() {}

    public init(@AccountValueRequirementsBuilder _ requirements: () -> [AnyAccountValueRequirement]) {
        self.requirements = [:]

        for requirement in requirements() {
            self.requirements[requirement.id] = requirement
        }
    }

    private func requirementType<Key: AccountValueKey>(for key: Key.Type) -> AccountValueType? {
        requirements[ObjectIdentifier(key)]?.type
    }

    public func configured<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        requirementType(for: key) != nil
    }

    public func required<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        requirementType(for: key) == .required
    }

    public func validateRequirements(in request: SignupRequest) throws {
        for requirement in requirements.values where requirement.type == .required {
            if !requirement.isContained(in: request.storage) {
                // TODO log the requirement name if its missing!
                print("Failed to have value in storage \(requirement)!")
                throw AccountValueRequirementsError.missingAccountValue
            }
        }
    }
}
