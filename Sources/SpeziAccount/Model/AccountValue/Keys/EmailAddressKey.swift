//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// The email address of a user.
public struct EmailAddressKey: AccountValueKey, OptionalComputedKnowledgeSource {
    public typealias StoragePolicy = AlwaysCompute
    public typealias Value = String

    public static let name = LocalizedStringResource("USER_ID_EMAIL", bundle: .atURL(from: .module))

    public static let category: AccountValueCategory = .contactDetails


    public static func compute<Repository: SharedRepository<AccountAnchor>>(from repository: Repository) -> String? {
        if let email = repository.get(Self.self) {
            // if we have manually stored a value for this key we return it
            return email
        }


        guard let activeService = repository[ActiveAccountServiceKey.self],
            activeService.configuration.userIdConfiguration.idType == .emailAddress else {
            return nil
        }

        // return the userId if it's a email address
        return repository[UserIdKey.self]
    }
}


extension AccountValueKeys {
    /// The email ``EmailAddressKey`` metatype.
    public var email: EmailAddressKey.Type {
        EmailAddressKey.self
    }
}


extension AccountValueStorageContainer {
    public var email: String? {
        storage[EmailAddressKey.self]
    }
}


// MARK: - UI
extension EmailAddressKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = EmailAddressKey

        @Binding private var email: Value

        public init(_ value: Binding<Value>) {
            self._email = value
        }

        public var body: some View {
            VerifiableTextField(Key.name, text: $email)
                .textContentType(.emailAddress)
                .disableFieldAssistants()
        }
    }
}
