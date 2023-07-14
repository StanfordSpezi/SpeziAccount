//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public class AccountValueStorageBuilder<Container: AccountValueStorageContainer> {
    private var contents: AccountValueStorage.StorageType

    public init() {
        self.contents = [:]
    }

    public init<Source: AccountValueStorageContainer>(from container: Source) {
        self.contents = container.storage.contents
    }

    @discardableResult
    public func add<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value) -> Self {
        contents[ObjectIdentifier(key)] = AccountValueStorage.Value<Key>(value: value)
        return self
    }

    @discardableResult
    public func add<Key: OptionalAccountValueKey>(_ key: Key.Type, value: Key.Value?) -> Self {
        contents[ObjectIdentifier(key)] = value.map { AccountValueStorage.Value<Key>(value: $0) }
        return self
    }

    @discardableResult
    public func remove<Key: AccountValueKey>(_ key: Key.Type) -> Self {
        contents[ObjectIdentifier(key)] = nil
        return self
    }

    @discardableResult
    public func add<Key: AccountValueKey>(
        _ key: Key.Type,
        value: @autoclosure () -> Key.Value,
        ifConfigured requirements: AccountValueRequirements
    ) -> Self {
        if requirements.configured(key) {
            return add(key, value: value())
        }
        return self
    }
}

// TODO move them?

extension AccountValueStorageBuilder where Container == AccountDetails {
    public func build<Service: AccountService>(owner accountService: Service) -> Container {
        let storage = AccountValueStorage(contents: contents)
        return Container(storage: storage, owner: accountService)
    }

    internal func build<Service: AccountService>(owner accountService: Service, injecting account: Account) -> Container {
        let container = build(owner: accountService)
        account.injectWeakAccount(into: container)
        return container
    }
}

extension AccountValueStorageBuilder where Container == SignupRequest {
    public func build(
        checking requirements: AccountValueRequirements? = nil
    ) throws -> Container {
        let storage = AccountValueStorage(contents: contents)
        let request = Container(storage: storage)

        if let requirements {
            try requirements.validateRequirements(in: request)
        }

        return request
    }
}
