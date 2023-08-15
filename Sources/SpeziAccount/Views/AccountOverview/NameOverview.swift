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

    private var service: any AccountService {
        accountDetails.accountService
    }

    @ObservedObject private var model: AccountOverviewFormViewModel

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    var dataEntryConfiguration: DataEntryConfiguration {
        .init(configuration: service.configuration, closures: model.validationClosures, focusedField: _focusedDataEntry, viewState: $viewState)
    }

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    userIdEditView
                } label: {
                    HStack {
                        UserIdKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails)
                    }
                }
            }

            if accountDetails.storage.get(PersonNameKey.self) != nil {
                Section {
                    NavigationLink {
                        nameEditView
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
            .viewStateAlert(state: $viewState)
            .navigationTitle("Name, E-Mail Address") // TODO navigation title
            .onDisappear {
                // TODO as we are reusing parent view model, clear all state!
            }
    }

    @ViewBuilder var nameEditView: some View {
        Form {
            PersonNameKey.dataEntryViewWithCurrentStoredValue(details: accountDetails, for: ModifiedAccountDetails.self)
            // TODO set focus on the first name!
        }
            .navigationTitle("Name")
            .environmentObject(dataEntryConfiguration)
            .environmentObject(model.modifiedDetailsBuilder)
            .toolbar {
                Button("Done", action: { print("Done")}) // TODO async button
                    .disabled(true) // TODO enable based on changes?
            }
            .onAppear {
                // TODO model.focusedDataEntry = PersonNameKey.focusState
            }
            .onDisappear {
                // TODO clear modified state! (and hooks?)
            }
    }

    @ViewBuilder var userIdEditView: some View {
        Form {
            UserIdKey.dataEntryViewWithCurrentStoredValue(details: accountDetails, for: ModifiedAccountDetails.self)
        }
            .navigationTitle("E-Mail Address")
            .environmentObject(dataEntryConfiguration)
            .environmentObject(model.modifiedDetailsBuilder)
            .toolbar {
                Button("Done", action: { print("Done")}) // TODO async button
                    .disabled(true) // TODO enable based on changes?
            }
            .onAppear {
                // TODO model.focusedDataEntry = PersonNameKey.focusState
            }
            .onDisappear {
                // TODO clear modified state! (and hooks?)
            }
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
