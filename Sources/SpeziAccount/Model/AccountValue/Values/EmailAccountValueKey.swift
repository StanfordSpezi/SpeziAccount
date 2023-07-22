//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


public struct EmailAccountValueKey: AccountValueKey, OptionalComputedKnowledgeSource {
    public typealias StoragePolicy = AlwaysCompute
    public typealias Value = String

    public static let signupCategory: SignupCategory = .contactDetails // TODO we could add phone number support as well!

    public static func compute<Repository: SharedRepository<AccountAnchor>>(from repository: Repository) -> String? {
        if let email = repository.get(Self.self) {
            // if we have manually stored a value for this key we return it
            return email
        }

        // otherwise return the userid if its a email address
        // TODO return nil if userId is not a email address!

        return repository[UserIdAccountValueKey.self]
    }
}


extension AccountValueKeys {
    public var email: EmailAccountValueKey.Type {
        EmailAccountValueKey.self
    }
}


extension AccountDetails {
    public var email: EmailAccountValueKey.Value? {
        get {
            // TODO we require api access to get as well!
            storage[EmailAccountValueKey.self]
        }
        set {
            storage[EmailAccountValueKey.self] = newValue
        }
    }
}


// MARK: - UI
extension EmailAccountValueKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = EmailAccountValueKey

        @Binding private var email: Value

        // TODO can we get a default for this type of init so its consistent?
        @StateObject private var validation = ValidationEngine(rules: .interceptingChain(.nonEmpty), .minimalEmail)

        public init(_ value: Binding<Value>) {
            self._email = value
        }

        public var body: some View {
            VerifiableTextField(UserIdType.emailAddress.localizedStringResource, text: $email)
                .environmentObject(validation)
                .fieldConfiguration(.emailAddress)
                .disableFieldAssistants()
        }
    }
}
