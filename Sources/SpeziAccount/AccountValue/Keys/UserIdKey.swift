//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziValidation
import SpeziViews
import SwiftUI


extension AccountDetails {
    /// A string-based, user-facing, unique user identifier.
    ///
    /// The `userId` is used to uniquely identify a given account at a given point in time.
    /// While the ``accountId`` is guaranteed to be stable, the `userId` might change over time.
    /// But it will still be unique.
    ///
    /// - Note: If an ``AccountService`` doesn't provide a `userId`, it will fallback to return the ``accountId``.
    ///
    /// The value might carry additional semantics. For example, the `userId` might, at the same time,
    /// be the primary email address of the user. Such semantics can be controlled by the ``AccountService``
    /// using the ``UserIdType`` configuration.
    ///
    /// - Note: You may also refer to the ``email`` to query the email address of an account.
    @AccountKey(name: LocalizedStringResource("USER_ID", bundle: .atURL(from: .module)), category: .credentials, initial: .empty(""))
    public var userId: String
}


@KeyEntry(\.userId)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier


extension AccountDetails.__Key_userId: ComputedKnowledgeSource {
    public typealias StoragePolicy = AlwaysCompute

    public static func compute<Repository: SharedRepository<AccountAnchor>>(from repository: Repository) -> String {
        if let value = repository.get(Self.self) {
            return value // return the userId if there is one stored
        }

        return repository[AccountKeys.accountId] // otherwise return the primary account key
    }
}


// MARK: - UI
extension AccountDetails.__Key_userId {
    public struct DataDisplay: DataDisplayView {
        private let value: String

        @Environment(\.accountServiceConfiguration)
        private var configuration

        public var body: some View {
            ListRow(configuration.userIdConfiguration.idType.localizedStringResource) {
                Text(verbatim: value)
            }
        }

        public init(_ value: String) {
            self.value = value
        }
    }
    
    public struct DataEntry: DataEntryView {
        @Environment(\.accountServiceConfiguration)
        private var configuration

        @Binding var userId: Value

        public var body: some View {
            VerifiableTextField(configuration.userIdConfiguration.idType.localizedStringResource, text: $userId)
                .textContentType(configuration.userIdConfiguration.textContentType)
#if !os(macOS)
                .keyboardType(configuration.userIdConfiguration.keyboardType)
#endif
                .disableFieldAssistants()
        }

        public init(_ value: Binding<Value>) {
            self._userId = value
        }
    }
}
