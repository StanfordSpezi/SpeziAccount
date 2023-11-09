//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziValidation
import SwiftUI


/// A string-based, user-facing, unique user identifier.
///
/// The `userId` is used to uniquely identify a given account at a given point in time.
/// While the ``AccountIdKey`` is guaranteed to be stable, the `userId` might change over time.
/// But it will still be unique.
///
/// - Note: If an ``AccountService`` doesn't provide a `userId`, it will fallback to return the ``AccountIdKey``.
///
/// The value might carry additional semantics. For example, the `userId` might, at the same time,
/// be the primary email address of the user. Such semantics can be controlled by the ``AccountService``
/// using the ``UserIdType`` configuration.
///
/// - Note: You may also refer to the ``EmailAddressKey`` to query the email address of an account.
public struct UserIdKey: AccountKey, ComputedKnowledgeSource {
    public typealias StoragePolicy = AlwaysCompute
    public typealias Value = String

    public static let name = LocalizedStringResource("USER_ID", bundle: .atURL(from: .module))

    public static let category: AccountKeyCategory = .credentials

    public static func compute<Repository: SharedRepository<AccountAnchor>>(from repository: Repository) -> String {
        if let value = repository.get(Self.self) {
            return value // return the userId if there is one stored
        }

        return repository[AccountIdKey.self] // otherwise return the primary account key
    }
}


extension AccountKeys {
    /// The userid ``UserIdKey`` metatype.
    public var userId: UserIdKey.Type {
        UserIdKey.self
    }
}


extension AccountValues {
    /// Access the user id of a user (see ``UserIdKey``).
    public var userId: String {
        storage[UserIdKey.self]
    }
}


// MARK: - UI
extension UserIdKey {
    public struct DataDisplay: DataDisplayView {
        public typealias Key = UserIdKey

        private let value: String

        @Environment(\.accountServiceConfiguration) private var configuration

        public var body: some View {
            SimpleTextRow(name: configuration.userIdConfiguration.idType.localizedStringResource) {
                Text(verbatim: value)
            }
        }

        public init(_ value: String) {
            self.value = value
        }
    }
    
    public struct DataEntry: DataEntryView {
        public typealias Key = UserIdKey

        @Environment(\.accountServiceConfiguration) private var configuration

        @Binding var userId: Value


        public init(_ value: Binding<Value>) {
            self._userId = value
        }

        public var body: some View {
            VerifiableTextField(configuration.userIdConfiguration.idType.localizedStringResource, text: $userId)
                .textContentType(configuration.userIdConfiguration.textContentType)
                .keyboardType(configuration.userIdConfiguration.keyboardType)
                .disableFieldAssistants()
        }
    }
}
