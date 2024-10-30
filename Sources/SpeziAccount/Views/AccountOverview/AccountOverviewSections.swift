//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import Spezi
import SpeziViews
import SwiftUI


/// A internal subview of ``AccountOverview`` that expects to be embedded into a `Form`.
@MainActor
@available(macOS, unavailable)
struct AccountOverviewSections<AdditionalSections: View>: View {
    private let closeBehavior: AccountOverview<AdditionalSections>.CloseBehavior
    private let deletionBehavior: AccountOverview<AdditionalSections>.AccountDeletionBehavior
    private let additionalSections: AdditionalSections

    private let accountDetails: AccountDetails
    private let model: AccountOverviewFormViewModel

    @Environment(Account.self)
    private var account

    @Environment(\.editMode)
    private var editMode
    @Environment(\.dismiss)
    private var dismiss

    @Binding private var destructiveViewState: ViewState

    private var showDeleteButton: Bool {
        switch deletionBehavior {
        case .disabled:
            false
        case .inEditMode:
            editMode?.wrappedValue.isEditing == true
        case .belowLogout:
            true
        }
    }

    private var showLogoutButton: Bool {
        switch deletionBehavior {
        case .inEditMode:
            editMode?.wrappedValue.isEditing != true
        default:
            true
        }
    }


    var body: some View {
        Section {
            AccountOverviewHeader(details: accountDetails)
        } header: {
            Spacer(minLength: 0)
                .listRowInsets(EdgeInsets())
        }
            .environment(\.defaultMinListHeaderHeight, 0)

        defaultSections

        sectionsView
            .injectEnvironmentObjects(configuration: accountDetails.accountServiceConfiguration, model: model)
            .animation(nil, value: editMode?.wrappedValue)

        additionalSections

        if showLogoutButton {
            Section {
                AsyncButton(role: .destructive, state: $destructiveViewState, action: {
                    model.presentingLogoutAlert = true
                }) {
                    Text("UP_LOGOUT", bundle: .module)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        if showDeleteButton {
            Section {
                AsyncButton(role: .destructive, state: $destructiveViewState, action: {
                    // While the action closure itself is not async, we rely on ability to render loading indicator
                    // of the AsyncButton which based on the externally supplied viewState.
                    model.presentingRemovalAlert = true
                }) {
                    Text("DELETE_ACCOUNT", bundle: .module)
                }
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    @ViewBuilder private var defaultSections: some View {
        let displayName = model.displaysNameDetails(accountDetails)
        let displaySecurity = model.displaysSignInSecurityDetails(accountDetails)

        if displayName || displaySecurity {
            Section {
                if displayName {
                    NavigationLink {
                        NameOverview(model: model, details: accountDetails)
                    } label: {
                        Label {
                            model.accountIdentifierLabel(configuration: account.configuration, accountDetails)
                        } icon: {
                            DetailsSectionIcon()
                        }
                    }
                }

                if displaySecurity {
                    NavigationLink {
                        SecurityOverview(model: model, details: accountDetails)
                    } label: {
                        Label {
                            Text("SIGN_IN_AND_SECURITY", bundle: .module)
                        } icon: {
                            SecuritySectionIcon()
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder private var sectionsView: some View {
        ForEach(model.editableAccountKeys(details: accountDetails).elements, id: \.key) { category, accountKeys in
            if !sectionIsEmpty(accountKeys) {
                Section {
                    // the id property of AccountKey.Type is static, so we can't reference it by a KeyPath, therefore the wrapper
                    let forEachWrappers = accountKeys.map { key in
                        ForEachAccountKeyWrapper(key)
                    }
                    
                    ForEach(forEachWrappers) { wrapper in
                        AccountKeyOverviewRow(details: accountDetails, for: wrapper.accountKey, model: model)
                    }
                        .onDelete { indexSet in
                            model.deleteAccountKeys(at: indexSet, in: accountKeys)
                        }
                } header: {
                    if let title = category.categoryTitle {
                        Text(title)
                    }
                }
            }
        }
    }
    
    init(
        model: AccountOverviewFormViewModel,
        details accountDetails: AccountDetails,
        close closeBehavior: AccountOverview<AdditionalSections>.CloseBehavior,
        deletion deletionBehavior: AccountOverview<AdditionalSections>.AccountDeletionBehavior,
        destructiveViewState: Binding<ViewState>,
        @ViewBuilder additionalSections: (() -> AdditionalSections) = { EmptyView() }
    ) {
        self.model = model
        self.accountDetails = accountDetails
        self.closeBehavior = closeBehavior
        self.deletionBehavior = deletionBehavior
        self._destructiveViewState = destructiveViewState
        self.additionalSections = additionalSections()
    }
    
    /// Computes if a given `Section` is empty. This is the case if we are **not** currently editing
    /// and the accountDetails don't have values stored for any of the provided ``AccountKey``.
    private func sectionIsEmpty(_ accountKeys: [any AccountKey.Type]) -> Bool {
        guard editMode?.wrappedValue.isEditing == false else {
            // there is always UI presented in EDIT mode
            return false
        }
        
        // we don't have to check for `addedAccountKeys` as these are only relevant in edit mode
        return accountKeys.allSatisfy { element in
            !accountDetails.contains(element)
        }
    }
}


#if DEBUG && !os(macOS)
#Preview {
    NavigationStack {
        AccountOverview {
            Section(header: Text(verbatim: "App")) {
                NavigationLink {
                    Text(String())
                } label: {
                    Text(verbatim: "General Settings")
                }
                NavigationLink {
                    Text(String())
                } label: {
                    Text(verbatim: "License Information")
                }
            }
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock(genderIdentity: .male))
        }
}

#Preview {
    NavigationStack {
        AccountOverview(deletion: .belowLogout) {
            Section(header: Text(verbatim: "App")) {
                NavigationLink {
                    Text(String())
                } label: {
                    Text(verbatim: "General Settings")
                }
                NavigationLink {
                    Text(String())
                } label: {
                    Text(verbatim: "License Information")
                }
            }
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock(genderIdentity: .male))
        }
}
#endif
