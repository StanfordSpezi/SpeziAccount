//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension AccountDetails {
    /// Use an `AccountKey` as a `CodingKey`.
    public struct AccountKeyCodingKey: CodingKey {
        public let stringValue: String
        public let intValue: Int? = nil

        /// Initialize from a raw string value.
        /// - Parameter stringValue: The string value key.
        public init?(stringValue: String) {
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

        /// Create a new CodingKey from the `AccountKey`.
        /// - Parameter key: A KeyPath to the key entry for the `AccountKey`.
        public init<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) {
            self.init(Key.self)
        }
    }
}


extension AccountDetails: Codable {
    /// Decodes the contents of a account details collection.
    ///
    /// - Warning: Decoding an `AccountDetails` requires knowledge of the ``AccountKey``s to decode. Therefore,
    ///     you must supply the keys using the the ``Swift/CodingUserInfoKey/accountDetailsKeys`` userInfo key.
    ///
    /// - Note: You can opt into lazy decoding using the ``Swift/CodingUserInfoKey/lazyAccountDetailsDecoding`` userInfo key.
    ///
    /// - Parameter decoder: The decoder.
    public init(from decoder: any Decoder) throws {
        guard let keys = decoder.userInfo[.accountDetailsKeys] as? [any AccountKey.Type] else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: """
                                  AccountKeys unspecified. Do decode AccountDetails you must specify requested AccountKey types \
                                  via the `accountDetailsKeys` CodingUserInfoKey.
                                  """
            ))
        }

        let requireKeys = decoder.userInfo[.requireAllKeys] as? Bool == true

        let container = try decoder.container(keyedBy: AccountKeyCodingKey.self)

        var visitor = DecoderVisitor(container, required: requireKeys)
        let details = keys.acceptAll(&visitor)

        if let error = visitor.errors.first {
            if let lazyDecoding = decoder.userInfo[.lazyAccountDetailsDecoding] as? Bool,
               lazyDecoding {
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
    /// - Parameter encoder: The encoder.
    public func encode(to encoder: any Encoder) throws {
        let container = encoder.container(keyedBy: AccountKeyCodingKey.self)

        var visitor = EncoderVisitor(container)
        let result = acceptAll(&visitor)

        if case let .failure(error) = result {
            throw error
        }
    }
}


extension AccountDetails {
    private struct EncoderVisitor: AccountValueVisitor {
        private var container: KeyedEncodingContainer<AccountKeyCodingKey>
        private var firstError: Error?

        init(_ container: KeyedEncodingContainer<AccountKeyCodingKey>) {
            self.container = container
        }

        mutating func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value) {
            guard firstError == nil else {
                return
            }

            do {
                try container.encode(value, forKey: .init(key))
            } catch {
                firstError = error
            }
        }

        func final() -> Result<Void, Error> {
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
        private var details = AccountDetails()

        private(set) var errors: [(any AccountKey.Type, Error)] = []

        init(_ container: KeyedDecodingContainer<AccountKeyCodingKey>, required: Bool) {
            self.container = container
            self.requireKeys = required
        }


        mutating func visit<Key: AccountKey>(_ key: Key.Type) {
            do {
                if requireKeys {
                    let value = try container.decode(Key.Value.self, forKey: .init(key))
                    details.set(Key.self, value: value)
                } else {
                    let value = try container.decodeIfPresent(Key.Value.self, forKey: .init(key))
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


extension CodingUserInfoKey {
    /// Provide the keys to decode to a decoder for `AccountDetails`.
    ///
    /// The decode implementation of `AccountDetails` needs prior knowledge of what keys to expect and which type they are.
    /// Therefore, you need a list of all ``AccountKey``s to expect. You can use this userInfo key to supply this list.
    ///
    /// ```swift
    /// let keys: [any AccountKey.Type] = [AccountKeys.name, AccountKeys.dateOfBirth]
    /// let decoder = JSONDecoder()
    /// decoder.userInfo[.accountDetailsKeys] = keys
    /// ```
    public static let accountDetailsKeys: CodingUserInfoKey = {
        guard let key = CodingUserInfoKey(rawValue: "edu.stanford.spezi.account-details-keys") else {
            preconditionFailure("Unable to create `accountDetailsKeys` CodingUserInfoKey!")
        }
        return key
    }()


    /// Decode `AccountDetails` with a best effort approach.
    ///
    /// By default, decoding `AccountDetails` throws an error if any of the values fail to decode. In certain situations, it might be useful to allow certain values to fail decoding
    /// and nonetheless use the details that succeeded decoding.
    /// You can opt into this behavior using this userInfo key.
    ///
    /// - Note: You can access all decoding errors using the ``AccountDetails/decodingErrors`` property. Make sure to reset this property to nil.
    ///
    /// ```swift
    /// let decoder = JSONDecoder()
    /// decoder.userInfo[.lazyAccountDetailsDecoding] = true
    ///
    /// var decoded = decoder.decode(AccountDetails.self, from: data)
    /// if let errors = decoded.decodingErrors {
    ///     // handle errors
    ///     decoded.decodingErrors = nil
    /// }
    /// ```
    public static let lazyAccountDetailsDecoding: CodingUserInfoKey = {
        guard let key = CodingUserInfoKey(rawValue: "edu.stanford.spezi.account.collect-errors-oob") else {
            preconditionFailure("Unable to create `collectCodingErrorsOutOfBand` CodingUserInfoKey!")
        }
        return key
    }()

    /// Require that all `accountDetailsKeys` are present.
    ///
    /// If this key is set to `true`, decoding will fail with a key present present in ``Swift/CodingUserInfoKey/accountDetailsKeys`` is not found while decoding.
    /// A value of `false` (the default) will decode only the keys found.
    ///
    /// ```swift
    /// let keys: [any AccountKey.Type] = [AccountKeys.name, AccountKeys.dateOfBirth]
    /// let decoder = JSONDecoder()
    /// decoder.userInfo[.accountDetailsKeys] = keys
    /// decoder.userInfo[.requireAllKeys] = true
    /// ```
    public static let requireAllKeys: CodingUserInfoKey = {
        guard let key = CodingUserInfoKey(rawValue: "edu.stanford.spezi.account.require-all-keys") else {
            preconditionFailure("Unable to create `requireAllKeys` CodingUserInfoKey!")
        }
        return key
    }()
}
