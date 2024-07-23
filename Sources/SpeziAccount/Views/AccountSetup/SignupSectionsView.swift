//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SwiftUI


/// This views renders the sections for the signup or signup-like views.
///
/// The view and it's subviews typically expect the following environment objects:
/// - The global ``Account`` object
/// - The internal `FocusStateObject` to pass down a `FocusState` (for the PersonNameKey implementation).
/// - An instance of ``AccountValuesBuilder`` according to the generic ``AccountValues`` type.
/// - An ``ValidationEngines`` object.
/// - The ``SwiftUI/EnvironmentValues/accountServiceConfiguration`` environment variable.
/// - The ``SwiftUI/EnvironmentValues/accountViewType`` environment variable.
struct SignupSectionsView<Storage: AccountValues>: View {
    private let sections: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]>
    private let storageType: Storage.Type

    @Environment(Account.self) private var account

    var body: some View {
        // OrderedDictionary `elements` conforms to RandomAccessCollection so we can directly use it
        ForEach(sections.elements, id: \.key) { category, accountKeys in
            Section {
                // the array doesn't change, so its fine to rely on the indices as identifiers
                ForEach(accountKeys.indices, id: \.self) { index in
                    VStack {
                        accountKeys[index].emptyDataEntryView(for: storageType)
                    }
                }
            } header: {
                if let title = category.categoryTitle {
                    Text(title)
                }
            } footer: {
                if category == .credentials && account.configuration[PasswordKey.self] != nil {
                    PasswordValidationRuleFooter(configuration: account.accountService.configuration)
                }
            }
        }
    }

    init(for storageType: Storage.Type, sections: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]>) {
        self.storageType = storageType
        self.sections = sections
    }
}


#if DEBUG
#Preview {
    Form {
        SignupSectionsView(for: SignupDetails.self, sections: [
            .credentials: [UserIdKey.self, PasswordKey.self],
            .name: [PersonNameKey.self]
        ])
    }
    .previewWith {
        AccountConfiguration(service: MockUserIdPasswordAccountService())
    }
}
#endif
