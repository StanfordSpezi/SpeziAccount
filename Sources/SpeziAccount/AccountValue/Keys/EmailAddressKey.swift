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


private struct EntryView: DataEntryView {
    @Binding private var email: String

    var body: some View {
        VerifiableTextField(AccountKeys.email.name, text: $email)
            .textContentType(.emailAddress)
            .disableFieldAssistants()
    }

    init(_ value: Binding<String>) {
        self._email = value
    }
}


extension AccountDetails {
#if compiler(<6)
    // In older compilers, we get a circular reference error when trying to add an extension (see end of file) to a type that is generated by a macro
    // Therefore, we manually expand the macro for older versions of the compiler.

    public struct __Key_email: AccountKey { // swiftlint:disable:this type_name
        public typealias Value = String

        public static let name = LocalizedStringResource("USER_ID_EMAIL", bundle: .atURL(from: .module))
        public static let identifier = "EmailAddressKey" // backwards compatibility with 1.0 releases
        public static let category: AccountKeyCategory = .contactDetails
        public struct DataEntry: DataEntryView {
            @Binding private var value: Value

            public var body: some View {
                EntryView($value)
            }

            public init(_ value: Binding<Value>) {
                self._value = value
            }
        }
    }
#endif

#if compiler(>=6)
    /// The email address of a user.
    @AccountKey(
        id: "EmailAddressKey", // backwards compatibility with 1.0 releases
        name: LocalizedStringResource("USER_ID_EMAIL", bundle: .atURL(from: .module)),
        category: .contactDetails,
        as: String.self,
        entryView: EntryView.self
    )
    public var email: String?
#else
    /// The email address of a user.
    public var email: String? {
        get {
            self [__Key_email.self]
        }
        set {
            self [__Key_email.self] = newValue
        }
    }
#endif
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
