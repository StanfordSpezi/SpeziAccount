//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SpeziViews
import SwiftUI
import Spezi


public struct PhoneNumbersView: View {
    @State private var viewState = ViewState.idle
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @Environment(Account.self) private var account
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @Environment(AccountDetailsBuilder.self) private var accountDetailsBuilder
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    let maxPhoneNumbers: Int
    
    private var addingDisabled: Bool {
        accountDetailsBuilder.get(AccountKeys.phoneNumbers)?.count ?? [].count >= maxPhoneNumbers
    }
    
    
    public var body: some View {
        if editMode?.wrappedValue.isEditing == false {
            if !(account.details?.phoneNumbers?.isEmpty ?? true) {
                Section {
                    ForEach(account.details?.phoneNumbers ?? [], id: \.self) { phoneNumber in
                        ListRow("Phone") {
                            Text(phoneNumber)
                        }
                    }
                } header: {
                    Text("Phone numbers")
                }
            }
        } else {
            Section {
                ForEach(accountDetailsBuilder.get(AccountKeys.phoneNumbers) ?? [], id: \.self) { phoneNumber in
                    ListRow("Phone") {
                        Text(phoneNumber)
                    }
                }
                    .onDelete { indexSet in
                        Task {
                            let values = accountDetailsBuilder.get(AccountKeys.phoneNumbers) ?? []
                            for index in indexSet {
                                do {
                                    try await phoneVerificationProvider.deletePhoneNumber(number: values[index])
                                    accountDetailsBuilder.set(AccountKeys.phoneNumbers, value: values.filter { $0 != values[index]})
                                } catch {
                                    viewState = .error(
                                        AnyLocalizedError(
                                            error: error,
                                            defaultErrorDescription: "Phone number could not be deleted. Try again."
                                        )
                                    )
                                }
                            }
                        }
                    }
                if !addingDisabled {
                    Button(action: {
                        phoneNumberViewModel.presentSheet = true
                    }, label: {
                        Text("Add Phone Number")
                    })
                }
            } header: {
                Text("Phone numbers")
            }
                .viewStateAlert(state: $viewState)
                .task {
                    accountDetailsBuilder.set(AccountKeys.phoneNumbers, value: account.details?.phoneNumbers ?? [])
                    phoneNumberViewModel.accountDetailsBuilder = accountDetailsBuilder
                }
        }
    }
    
    
    public init(maxPhoneNumbers: Int = 1) {
        self.maxPhoneNumbers = max(1, maxPhoneNumbers)
    }
}


#if DEBUG
#Preview {
    PhoneNumbersView()
}
#endif
