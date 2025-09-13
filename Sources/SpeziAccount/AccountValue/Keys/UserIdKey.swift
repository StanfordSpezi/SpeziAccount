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


private struct DisplayView: DataDisplayView {
    private let value: String

    @Environment(\.accountServiceConfiguration)
    private var configuration

    var body: some View {
        ListRow(configuration.userIdConfiguration.idType.localizedStringResource) {
            Text(verbatim: value)
        }
    }

    init(_ value: String) {
        self.value = value
    }
}


private struct EntryView: DataEntryView {
    @Environment(\.accountServiceConfiguration)
    private var configuration

    @Binding private var userId: String

    var body: some View {
        VerifiableTextField(configuration.userIdConfiguration.idType.localizedStringResource, text: $userId)
            .textContentType(configuration.userIdConfiguration.textContentType)
#if !os(macOS) && !os(watchOS)
            .keyboardType(configuration.userIdConfiguration.keyboardType)
#endif
            .disableFieldAssistants()
    }

    init(_ value: Binding<String>) {
        self._userId = value
    }
}


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
    @AccountKey(
        name: LocalizedStringResource("USER_ID", bundle: .atURL(from: .module)),
        category: .credentials,
        as: String.self,
        displayView: DisplayView.self,
        entryView: EntryView.self
    )
    public var userId: String
}


@KeyEntry(\.userId)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier


extension AccountDetails.__Key_userId: ComputedKnowledgeSource {
    public typealias StoragePolicy = AlwaysCompute

    public static func compute(from repository: AccountStorage) -> String {
        if let value = repository.get(Self.self) {
            return value // return the userId if there is one stored
        }

        return repository[AccountKeys.accountId] // otherwise return the primary account key
    }
}
