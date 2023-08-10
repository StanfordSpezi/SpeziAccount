//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A `KnowledgeSource` that implements a configuration option for ``AccountServiceConfiguration``.
///
/// `AccountServiceConfigurationKey` are `KnowledgeSource`s which are anchored to the ``AccountServiceConfigurationStorageAnchor``
/// and have the requirement that the protocol-adopting type is the `Value` itself.
///
/// Below is a minimal code example on how to implement your own `AccountServiceConfigurationKey` and make it easily
/// accessible via an extension to the ``AccountServiceConfiguration``.
///
/// ```swift
/// public struct MyOwnOption: AccountServiceConfigurationKey {
///     public let myOptionString: String
/// }
///
/// extension AccountServiceConfiguration {
///     public var myOption: String {
///         // you may also just return the `MyOwnOption` as a whole if it makes sense
///         storage[MyOwnOption.self].myOptionString
///     }
/// }
/// ```
///
/// - Note: Refer to the [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository)
///     documentation to leverage the full potential of what's possible with `KnowledgeSource`s. Particularly, how to provide default
///     values or compute the value dependent on other configuration options.
public protocol AccountServiceConfigurationKey: KnowledgeSource<AccountServiceConfigurationStorageAnchor>, Sendable where Value == Self {}


extension AccountServiceConfigurationKey {
    /// This method is used internally to store the instance into the a ``AccountServiceConfigurationStorage``
    /// when having a type-erased view on the instance.
    func store(into repository: inout AccountServiceConfigurationStorage) {
        repository[Self.self] = self
    }
}
