//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension AccountDetails {
    /// Use an `AccountKey` as a `CodingKey`.
    public struct AccountKeyCodingKey: CodingKey {
        public let stringValue: String
        public let intValue: Int? = nil

        /// Initialize from a raw string value.
        /// - Parameter stringValue: The string value key.
        public init(stringValue: String) {
            self.stringValue = stringValue
        }

        /// Unavailable.
        public init?(intValue: Int) {
            nil
        }

        /// Create a new CodingKey from the `AccountKey`.
        /// - Parameter key: The `AccountKey`.
        public init<Key: AccountKey>(_ key: Key.Type) {
            self.stringValue = key.identifier
        }

        fileprivate init<Key: AccountKey>(_ key: Key.Type, mapping: IdentifierMapping?) {
            self.stringValue = mapping?.identifier(for: key) ?? key.identifier
        }

        /// Create a new CodingKey from the `AccountKey`.
        /// - Parameter keyPath: A KeyPath to the key entry for the `AccountKey`.
        public init<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) {
            self.init(Key.self)
        }
    }
}


extension AccountDetails {
    /// The configuration that is required to decode account details.
    ///
    /// ```swift
    /// let keys: [any AccountKey.Type] = [AccountKeys.name, AccountKeys.dateOfBirth]
    ///
    /// let decoder = JSONDecoder()
    /// let configuration = AccountDetails.DecodingConfiguration(keys: keys)
    /// try decoder.decode(AccountDetails.self, from: data, configuration: configuration)
    /// ```
    public struct DecodingConfiguration {
        /// The list of keys to decode.
        ///
        /// The decode implementation of `AccountDetails` needs prior knowledge of what keys to expect and which type they are.
        /// Therefore, you need a list of all ``AccountKey``s to expect.
        public let keys: [any AccountKey.Type]
        /// Customize the identifier mapping.
        ///
        /// Instead of using the ``AccountKey/identifier`` defined by the account key, you can provide a custom mapping when encoding and decoding.
        /// Identifiers that are not specified but requested to be decoded or encoded will fallback to the identifier provided by the account key.
        ///
        /// - Important: You must specify the `identifierMapping` for both the encoder and decoder.
        public let identifierMapping: [String: any AccountKey.Type]? // swiftlint:disable:this discouraged_optional_collection
        /// Decode `AccountDetails` with a best effort approach.
        ///
        /// By default, decoding `AccountDetails` throws an error if any of the values fail to decode. In certain situations, it might be useful to allow certain values to fail decoding
        /// and nonetheless use the details that succeeded decoding.
        /// You can opt into this behavior using this option.
        ///
        /// - Note: You can access all decoding errors using the ``AccountDetails/decodingErrors`` property. Make sure to reset this property to nil.
        ///
        /// ```swift
        /// let keys: [any AccountKey.Type] = [AccountKeys.name, AccountKeys.dateOfBirth]
        /// let decoder = JSONDecoder()
        /// let configuration = AccountDetails.DecodingConfiguration(keys: keys, lazyDecoding: true)
        ///
        /// let decoded = try decoder.decode(AccountDetails.self, from: data, configuration: configuration)
        /// if let errors = decoded.decodingErrors {
        ///     // handle errors ...
        ///     decoded.decodingErrors = nil
        /// }
        /// ```
        public let lazyDecoding: Bool
        /// Require that all `accountDetailsKeys` are present.
        ///
        /// If this option is set to `true`, decoding will fail if a key present in ``keys`` is not found while decoding.
        /// A value of `false` (the default) will decode only the keys found.
        public let requireAllKeys: Bool

        /// Create a new decoding configuration.
        /// - Parameters:
        ///   - keys: The list of keys to decode.
        ///   - identifierMapping: Customize the identifier mapping.
        ///   - lazyDecoding: Decode `AccountDetails` with a best effort approach.
        ///   - requireAllKeys: Require that all `accountDetailsKeys` are present.
        public init(
            keys: [any AccountKey.Type],
            identifierMapping: [String: any AccountKey.Type]? = nil, // swiftlint:disable:this discouraged_optional_collection
            lazyDecoding: Bool = false,
            requireAllKeys: Bool = false
        ) {
            self.keys = keys
            self.identifierMapping = identifierMapping
            self.lazyDecoding = lazyDecoding
            self.requireAllKeys = requireAllKeys
        }
    }

    /// Supply additional configuration when encoding.
    ///
    /// ```swift
    /// let details = AccountDetails()
    /// let mapping: [String: any AccountKey.Type] = [
    ///     "DateOfBirthKey": AccountKeys.dateOfBirth
    /// ]
    ///
    /// let encoder = JSONEncoder()
    /// let configuration = AccountDetails.EncodingConfiguration(identifierMapping: mapping)
    /// try encoder.encode(details, configuration: configuration)
    /// ```
    public struct EncodingConfiguration {
        /// Customize the identifier mapping.
        ///
        /// Instead of using the ``AccountKey/identifier`` defined by the account key, you can provide a custom mapping when encoding and decoding.
        /// Identifiers that are not specified but requested to be decoded or encoded will fallback to the identifier provided by the account key.
        ///
        /// - Important: You must specify the `identifierMapping` for both the encoder and decoder.
        public let identifierMapping: [String: any AccountKey.Type]? // swiftlint:disable:this discouraged_optional_collection

        /// Create a new encoding configuration.
        /// - Parameters:
        ///   - identifierMapping: Customize the identifier mapping.
        public init(
            identifierMapping: [String: any AccountKey.Type]? = nil // swiftlint:disable:this discouraged_optional_collection
        ) {
            self.identifierMapping = identifierMapping
        }
    }
}


extension AccountDetails.DecodingConfiguration: Sendable {}


extension AccountDetails.EncodingConfiguration: Sendable {}


extension AccountDetails: CodableWithConfiguration, Encodable {
    /// Decodes the contents of a account details collection.
    ///
    /// Use the ``DecodingConfiguration`` to supply mandatory options, like providing the list of ``AccountKey``s to decode.
    ///
    /// - Note: You can opt into lazy decoding using the ``DecodingConfiguration/lazyDecoding`` option or customize the identifier mapping
    ///     using ``DecodingConfiguration/identifierMapping``.
    ///
    /// - Parameters:
    ///   - decoder: The decoder.
    ///   - configuration: The decoding configuration.
    public init(from decoder: any Decoder, configuration: DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: AccountKeyCodingKey.self)

        let mapping = configuration.identifierMapping.map { IdentifierMapping(mapping: $0) }

        var visitor = DecoderVisitor(container, required: configuration.requireAllKeys, mapping: mapping)
        let details = configuration.keys.acceptAll(&visitor)

        if let error = visitor.errors.first {
            if configuration.lazyDecoding {
                self = details
                self.decodingErrors = visitor.errors
            } else {
                throw error.1
            }
        } else {
            self = details
        }
    }

    /// Encode the contents of the collection.
    ///
    /// This implementation iterates over all ``AccountKey``s and encodes them with their respective `Codable` implementation.
    ///
    /// - Note: You can customize the identifier mapping using the ``EncodingConfiguration``.
    ///
    /// - Parameter encoder: The encoder.
    public func encode(to encoder: any Encoder) throws {
        try encode(to: encoder, configuration: EncodingConfiguration())
    }

    /// Encode the contents of the collection.
    ///
    /// This implementation iterates over all ``AccountKey``s and encodes them with their respective `Codable` implementation.
    /// Further, it uses the custom identifier mapping from ``EncodingConfiguration/identifierMapping``.
    ///
    /// - Parameters:
    ///   - encoder: The encoder.
    ///   - configuration: The encoding configuration.
    public func encode(to encoder: any Encoder, configuration: EncodingConfiguration) throws {
        let container = encoder.container(keyedBy: AccountKeyCodingKey.self)

        let mapping = configuration.identifierMapping.map { IdentifierMapping(mapping: $0) }

        var visitor = EncoderVisitor(container, mapping: mapping)
        let result = acceptAll(&visitor)

        if case let .failure(error) = result {
            throw error
        }
    }
}


extension AccountDetails {
    fileprivate struct IdentifierMapping {
        let mapping: [ObjectIdentifier: String]

        init(mapping: [String: any AccountKey.Type]) {
            self.mapping = mapping.reduce(into: [:]) { partialResult, entry in
                partialResult[ObjectIdentifier(entry.value)] = entry.key
            }
        }

        func identifier<Key: AccountKey>(for key: Key.Type) -> String? {
            mapping[ObjectIdentifier(key)]
        }
    }

    private struct EncoderVisitor: AccountValueVisitor {
        private let mapping: IdentifierMapping?
        private var container: KeyedEncodingContainer<AccountKeyCodingKey>
        private var firstError: (any Error)?

        init(_ container: KeyedEncodingContainer<AccountKeyCodingKey>, mapping: IdentifierMapping?) {
            self.container = container
            self.mapping = mapping
        }

        mutating func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value) {
            guard firstError == nil else {
                return
            }

            do {
                try container.encode(value, forKey: AccountKeyCodingKey(key, mapping: mapping))
            } catch {
                firstError = error
            }
        }

        func final() -> Result<Void, any Error> {
            if let firstError {
                .failure(firstError)
            } else {
                .success(())
            }
        }
    }

    private struct DecoderVisitor: AccountKeyVisitor {
        private let container: KeyedDecodingContainer<AccountKeyCodingKey>
        private let requireKeys: Bool
        private let mapping: IdentifierMapping?
        private var details = AccountDetails()

        private(set) var errors: [(any AccountKey.Type, any Error)] = []

        init(_ container: KeyedDecodingContainer<AccountKeyCodingKey>, required: Bool, mapping: IdentifierMapping?) {
            self.container = container
            self.requireKeys = required
            self.mapping = mapping
        }


        mutating func visit<Key: AccountKey>(_ key: Key.Type) {
            do {
                let codingKey = AccountKeyCodingKey(key, mapping: mapping)

                if requireKeys {
                    let value = try container.decode(Key.Value.self, forKey: codingKey)
                    details.set(Key.self, value: value)
                } else {
                    let value = try container.decodeIfPresent(Key.Value.self, forKey: codingKey)
                    if let value {
                        details.set(Key.self, value: value)
                    }
                }
            } catch {
                errors.append((key, error))
            }
        }

        func final() -> AccountDetails {
            details
        }
    }
}
