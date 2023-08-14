//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziViews
import SwiftUI


/// A internal subview of ``AccountOverview`` that expects to be embedded into a `Form`.
struct AccountOverviewForm: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }

    @EnvironmentObject private var account: Account
    @Environment(\.editMode) private var editMode

    @StateObject private var modifiedDetailsBuilder = ModifiedAccountDetails.Builder()
    // We just use @State here for the class type, as there is nothing in it that should trigger an UI update.
    // However, we need to preserve the class state across UI updates.
    @State private var validationClosures = DataEntryValidationClosures()

    @Binding private var viewState: ViewState
    @FocusState private var focusedDataEntry: String? // see `AccountValueKey.Type/focusState`
    @State private var editModeCancelled = false

    private var accountValuesBySections: OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]> {
        // We could also just iterate over the `AccountDetails` and show whatever is present.
        // However, we deliberately don't do that. We have the `.supported` requirement option for such cases.
        // And not doing this allows for modelling "shadow" account values that are present but never shown to the user
        // to manage additional state.

        let results = account.configuration.reduce(into: OrderedDictionary()) { result, requirement in
            guard requirement.anyKey.category != AccountValueCategory.credentials else {
                // TODO name shouldn't be displayed!!!!
                return
            }
            // TODO we need to handle `Credentials` categories differently!
            //  => assume: UserId will be the only credential that is not about passwords!
            //  => everything else is placed into the `Password & Security` section(?)
            //   => can we do different categories for password and userId?

            result[requirement.anyKey.category, default: []] += [requirement.anyKey]
        }

        return results.mapValues { value in
            // We make sure that for all values where there isn't a value stored in the `AccountDetails`
            // the `add` button is presented at the bottom of the section.
            value.sorted { lhs, rhs in
                // we are (strictly) in increasing order, if lhs is true and rhs is false
                lhs.isContained(in: accountDetails) && !rhs.isContained(in: accountDetails)
            }
        }
    }

    private var dataEntryConfiguration: DataEntryConfiguration {
        .init(configuration: service.configuration, validationClosures: validationClosures, focusedField: _focusedDataEntry, viewState: $viewState)
    }


    private var accountHeadline: String {
        // we gracefully check if the account details have a name, bypassing the subscript overloads
        if let name = accountDetails.storage.get(PersonNameKey.self) {
            return name.formatted(.name(style: .long))
        } else {
            // otherwise we display the userId
            return accountDetails.userId
        }
    }

    private var accountSubheadline: String? {
        if accountDetails.storage.get(PersonNameKey.self) != nil {
            // If the accountHeadline uses the name, we display the userId as the subheadline
            return accountDetails.userId
        } else if accountDetails.userIdType != .emailAddress,
                  let email = accountDetails.email {
            // Otherwise, headline will be the userId. Therefore, we check if the userId is not already
            // displaying the email address. In this case the subheadline will be the email if available.
            return email
        }

        return nil
    }


    var body: some View {
        accountHeaderSection
            // Every `Section` is basically a `Group` view. So we have to be careful where to place modifiers
            // as they might otherwise be rendered for every element in the Section/Group, e.g., placing multiple buttons.
            .interactiveDismissDisabled(editMode?.wrappedValue.isEditing ?? false)
            // TODO hide back button? and place a custom one if there may be discarded changes!
            .onChange(of: editMode?.wrappedValue, perform: onEditModeChange)
            .toolbar {
                if editMode?.wrappedValue.isEditing == true {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(role: .cancel, action: cancelAction) {
                            Text("Cancel")
                        }
                    }
                }
            }

        Section {
            // TODO "Name" if available, followed by userId name!
            NavigationLink("Name, E-Mail Address", value: "True")
            NavigationLink("Password & Security", value: "asdf") // TODO how to extend? password only if password is in signup requirements!
        }

        sectionsView
            .environment(\.dataEntryConfiguration, dataEntryConfiguration)
            .environmentObject(modifiedDetailsBuilder)
            .animation(nil, value: editMode?.wrappedValue)
    }

    @ViewBuilder var accountHeaderSection: some View {
        HStack {
            Spacer()
            VStack {
                // we gracefully check if the account details have a name, bypassing the subscript overloads
                if let name = accountDetails.storage.get(PersonNameKey.self) {
                    UserProfileView(name: name) // TODO may we support an "image loader"?
                        .frame(height: 90) // TODO verify on other devices?
                }

                Text(accountHeadline)
                    .font(.title2)
                    .fontWeight(.semibold)

                if let accountSubheadline {
                    Text(accountSubheadline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    @ViewBuilder private var sectionsView: some View {
        ForEach(accountValuesBySections.elements, id: \.key) { category, accountValues in
            if !sectionIsEmpty(accountValues) {
                Section {
                    // While the stored values in `AccountDetails` can change, the list of displayed
                    // account values (the AccountValueConfiguration) does not change! So index based access is okay here.
                    ForEach(accountValues.indices, id: \.self) { index in
                        buildRow(for: accountValues[index])
                    }
                } header: {
                    if let title = category.categoryTitle {
                        Text(title)
                    }
                }
            }
        }
    }


    init(details account: AccountDetails, state viewState: Binding<ViewState>) {
        self.accountDetails = account
        self._viewState = viewState
    }


    @ViewBuilder
    private func buildRow(for accountValue: any AccountValueKey.Type) -> some View {
        if editMode?.wrappedValue.isEditing == true {
            HStack {
                if let view = accountValue.dataEntryViewWithCurrentStoredValue(from: accountDetails, for: ModifiedAccountDetails.self) {
                    view
                } else {
                    Button(action: {
                        addDetail(for: accountValue)
                    }) {
                        Text("Add \(accountValue.name)") // TODO localize
                    }
                }
            }
        } else {
            if let view = accountValue.dataDisplayViewWithCurrentStoredValue(from: accountDetails) {
                HStack {
                    view
                }
            }
        }
    }


    private func cancelAction() {
        print("cancel")
        // TODO this triggers the save thingy!
        editModeCancelled = true
        editMode?.wrappedValue = .inactive
    }

    private func addDetail(for value: any AccountValueKey.Type) {
        print("adding \(value.name)")
    }

    private func onEditModeChange(newValue: EditMode?) {
        if editModeCancelled {
            editModeCancelled = false
            return
        }

        if newValue == .inactive {
            // TODO control loading indicator of parentview!
            print("LOADING!")
            viewState = .processing // TODO reset indicator!
            Task {
                try? await Task.sleep(for: .seconds(1))
                viewState = .idle
            }
        }
    }

    /// Computes if a given `Section` is empty. This is the case if we are **not** currently editing
    /// and the accountDetails don't have values stored for any of the provided ``AccountValueKey``.
    private func sectionIsEmpty(_ accountValues: [any AccountValueKey.Type]) -> Bool {
        guard editMode?.wrappedValue.isEditing == false else {
            // there is always UI presented in EDIT mode
            return false
        }

        return accountValues.allSatisfy { element in
            !element.isContained(in: accountDetails)
        }
    }
}
