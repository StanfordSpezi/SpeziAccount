//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct SecurityOverview: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }

    @ObservedObject private var model: AccountOverviewFormViewModel

    @State private var presentingPasswordChangeSheet = false

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    var dataEntryConfiguration: DataEntryConfiguration {
        .init(configuration: service.configuration, closures: model.validationClosures, focusedField: _focusedDataEntry, viewState: $viewState)
    }


    var body: some View {
        Form {
            Button("Change Password", action: {
                presentingPasswordChangeSheet = true
            })
                .sheet(isPresented: $presentingPasswordChangeSheet) {
                    passwordChangeSheet
                }

            // TODO place all the credentials things here?
            //  => assume: UserId will be the only credential that is not about passwords!
        }
            .viewStateAlert(state: $viewState)
            .navigationTitle("Password & Security") // TODO titlte
            .onDisappear {
                // TODO reset all state!
            }
    }

    @State private var newPassword: String = ""
    @State private var repeatPassword: String = ""

    @ViewBuilder private var passwordChangeSheet: some View {
        NavigationStack {
            Form {
                Section {
                    VerifiableTextField("Password", text: $newPassword)
                        .textContentType(.newPassword)
                        .environmentObject(ValidationEngine())
                    VerifiableTextField("Repeat Password", text: $repeatPassword)
                        .textContentType(.newPassword)
                        .environmentObject(ValidationEngine())
                } footer: {
                    PasswordValidationRuleFooter(configuration: accountDetails.accountServiceConfiguration)
                }

                // TODO place password guidelines
                // => "Your password must be at least 8 characters long."
            }
                .environmentObject(dataEntryConfiguration)
                .environmentObject(model.modifiedDetailsBuilder)
                .navigationTitle("Change Password")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Done", action: {})
                    }
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button("Cancel", action: {
                            presentingPasswordChangeSheet = false
                            // TODO dismiss should also work in view hierachy!!
                        })
                    }
                }
        }
    }

    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }
}


#if DEBUG
struct SecurityOverview_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello") // TODO can we provide a preview?
    }
}
#endif
