//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NameOverview: View {
    private let accountDetails: AccountDetails

    @ObservedObject private var model: AccountOverviewFormViewModel

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    SingleEditView<UserIdKey>(model: model, details: accountDetails)
                } label: {
                    HStack {
                        UserIdKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails)
                    }
                }
            }

            if accountDetails.name != nil {
                Section {
                    NavigationLink {
                        SingleEditView<PersonNameKey>(model: model, details: accountDetails)
                    } label: {
                        HStack {
                            PersonNameKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails)
                        }
                    }
                } header: {
                    if let title = PersonNameKey.category.categoryTitle {
                        Text(title)
                    }
                }
            }
        }
            .navigationTitle(model.accountIdentifierLabel(details: accountDetails))
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }
}


#if DEBUG
struct NameOverview_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello") // TODO can we provide a preview?
    }
}
#endif