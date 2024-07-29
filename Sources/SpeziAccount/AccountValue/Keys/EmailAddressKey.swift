//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziValidation
import SwiftUI


extension AccountDetails {
    /// The email address of a user.
    @AccountKey(name: LocalizedStringResource("USER_ID_EMAIL", bundle: .atURL(from: .module)), category: .contactDetails, initial: .empty(""))
    public var email: String?
}


@KeyEntry(\.email)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier


extension AccountDetails.__Key_email: OptionalComputedKnowledgeSource {
    public typealias StoragePolicy = AlwaysCompute

    public static func compute<Repository: SharedRepository<AccountAnchor>>(from repository: Repository) -> String? {
        if let email = repository.get(Self.self) {
            // if we have manually stored a value for this key we return it
            return email
        }

        guard let configuration = repository[AccountServiceConfigurationDetailsKey.self],
              case .emailAddress = configuration.userIdConfiguration.idType else {
            return nil
        }

        // return the userId if it's a email address
        return repository[AccountKeys.userId]
    }
}


// MARK: - UI
extension AccountDetails.__Key_email {
    public struct DataEntry: DataEntryView {
        @Binding private var email: Value

        public init(_ value: Binding<Value>) {
            self._email = value
        }

        public var body: some View {
            VerifiableTextField(AccountKeys.email.name, text: $email)
                .textContentType(.emailAddress)
                .disableFieldAssistants()
        }
    }
}
