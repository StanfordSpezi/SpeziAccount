//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public class AccountValueStorageBuilder {
    private var contents: AccountValueStorage.StorageType

    public init() {
        self.contents = [:]
    }

    @discardableResult
    public func add<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value) -> Self {
        contents[ObjectIdentifier(key)] = Entry<Key>(value: value)
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

    public func build<Container: AccountValueStorageContainer>(_ type: Container.Type = Container.self) -> Container {
        Container(storage: AccountValueStorage(contents: contents))
    }

    public func build<Container: AccountValueStorageContainer>(
        _ type: Container.Type = Container.self,
        checking requirements: AccountValueRequirements? = nil
    ) -> Container {
        let storage = AccountValueStorage(contents: contents)

        if let requirements {
            // TODO sanity checks that all required properties are set!
            requirements.validateRequirements(in: storage)
        }

        return Container(storage: storage)
    }
}
