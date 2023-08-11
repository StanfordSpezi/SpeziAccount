//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections

// TODO do modifications of values (also the edit view)
//    => requires iterable of `AccountDetails`, everything with a concept! (how to we establish an order there?)
//    => rethink requirements specification: required, optional in signup (presented), optional (not presented)
//  do the account service specifies which requirements they support and delegate everything else somewhere else!


// TODO maybe rename type to `SignupRequirements`
//  maybe consider new name, as these are only what gets displayed!
public struct AccountValueRequirements {
    public static var `default` = AccountValueRequirements { // TODO might a simple array be nicer?
        \.userId
        \.password
        \.name
        \.genderIdentity
        \.dateOfBirth
    }

    // its important for displaying purposes to keep the order.
    private var requirements: OrderedDictionary<ObjectIdentifier, AnyAccountValueRequirement> = [:]

    public init() {}

    public init(@AccountValueRequirementsBuilder _ requirements: () -> [AnyAccountValueRequirement]) {
        self.requirements = [:]

        for requirement in requirements() {
            self.requirements[requirement.id] = requirement
        }
    }

    private func requirementType<Key: AccountValueKey>(for keyPath: KeyPath<AccountValueKeys, Key.Type>) -> AccountValueKind? {
        requirements[Key.id]?.type
    }

    public func configured<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> Bool {
        requirementType(for: keyPath) != nil
    }

    public func required<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> Bool {
        requirementType(for: keyPath) == .required
    }

    public func validateRequirements(in request: SignupDetails) throws {
        for requirement in requirements.values where requirement.type == .required {
            if !requirement.isContained(in: request.storage) {
                LoggerKey.defaultValue.warning("\(requirement.description) was required to be provided but weren't provided!")
                throw AccountValueRequirementsError.missingAccountValue(requirement.description)
            }
        }
    }
}


extension AccountValueRequirements: Collection {
    public typealias Index = OrderedDictionary<ObjectIdentifier, AnyAccountValueRequirement>.Index

    public var startIndex: Index {
        requirements.values.startIndex
    }

    public var endIndex: Index {
        requirements.values.endIndex
    }


    public func index(after index: Index) -> Index {
        requirements.values.index(after: index)
    }


    public subscript(position: Index) -> AnyAccountValueRequirement {
        requirements.values[position]
    }
}
