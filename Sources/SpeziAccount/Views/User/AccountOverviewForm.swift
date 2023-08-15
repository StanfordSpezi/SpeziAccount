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
    @Environment(\.logger) private var logger
    @Environment(\.processingDebounceDuration) var processingDebounceDuration
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss

    @State private var addedAccountValues: OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]> = [:]
    @StateObject private var modifiedDetailsBuilder = ModifiedAccountDetails.Builder()
    // We just use @State here for the class type, as there is nothing in it that should trigger an UI update.
    // However, we need to preserve the class state across UI updates.
    @State private var validationClosures = DataEntryValidationClosures()

    @Binding private var viewState: ViewState
    @FocusState private var focusedDataEntry: String?

    // TODO can we split stuff out into subviews?
    @State private var actionTask: Task<Void, Never>?
    @State private var presentingCancellationDialog = false

    // TODO at this point a ViewModel would be ideal right?
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
            .interactiveDismissDisabled(!modifiedDetailsBuilder.isEmpty) // prevent skipping our confirmation dialog
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing ?? false) // we show a cancel button in this case
            .onChange(of: editMode?.wrappedValue, perform: onEditModeChange)
            .toolbar {
                if editMode?.wrappedValue.isEditing == true {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(role: .cancel, action: cancelAction) {
                            Text("Cancel") // TODO localized
                        }
                    }
                }
            }
            // TODO not sure if the title is displayed!
            .confirmationDialog(Text("DISCARD_CHANGES_TITLE".localized(.module)), isPresented: $presentingCancellationDialog) {
                Button(role: .destructive, action: discardChangesAction) {
                    Text("DISCARD_CHANGES".localized(.module))
                }
                Button(role: .cancel, action: {}) {
                    Text("KEEP_EDITING".localized(.module))
                }
            }

        Section {
            // TODO "Name" if available, followed by userId name!
            NavigationLink("Name, E-Mail Address", value: "True") // TODO locales
            NavigationLink("Password & Security", value: "asdf") // TODO how to extend? password only if password is in signup requirements!
        }

        sectionsView
            .environmentObject(dataEntryConfiguration)
            .environmentObject(modifiedDetailsBuilder)
            .animation(nil, value: editMode?.wrappedValue)

            // TODO think about how the app would react to removed accounts? => app could also allow to skip account setup?
            Group {
                if editMode?.wrappedValue.isEditing == true {
                    AsyncButton("Delete Account", role: .destructive) {
                        // TODO confirm removal
                        try? await service.delete() // TODO catch and default error!
                        dismiss()
                    }
                } else {
                    AsyncButton("Logout", role: .destructive) {
                        try? await service.logout() // TODO catch and default error
                        dismiss()
                    }
                }
            }
                .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder var accountHeaderSection: some View {
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
            .frame(maxWidth: .infinity, alignment: .center)
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
                        .onDelete { index in
                            // TODO we need to track deleted elements and also hide them in the implementation
                            //   => additionally, our ModifiedDetails data structure isn't enough anymore!
                            print("deleted \(index)")
                        }

                    // addedAccountValues will only be populated in edit mode, so no need to explicitly check for it
                    if let addedValues = addedAccountValues[category] {
                        // as addedValues is append only, the indices are stable identifiers
                        ForEach(addedValues.indices, id: \.self) { index in
                            addedValues[index].emptyDataEntryView(for: ModifiedAccountDetails.self)
                        }
                            .onDelete { index in
                                // TODO so the index is not a stable identifier anymore!
                                addedAccountValues[category]?.remove(atOffsets: index)
                                print("deleted index \(index)")
                            }
                    }
                } header: {
                    if let title = category.categoryTitle {
                        Text(title)
                    }
                }
            }
        }
    }


    init(details account: AccountDetails, state viewState: Binding<ViewState>, focusedField: FocusState<String?>) {
        self.accountDetails = account
        self._viewState = viewState
        self._focusedDataEntry = focusedField
    }


    @ViewBuilder
    private func buildRow(for accountValue: any AccountValueKey.Type) -> some View {
        if editMode?.wrappedValue.isEditing == true {
            if let view = accountValue.dataEntryViewWithCurrentStoredValue(from: accountDetails, for: ModifiedAccountDetails.self) {
                HStack {
                    view
                }
                    .deleteDisabled(account.configuration[accountValue]?.requirement == .required)
            } else if !addedAccountValues[accountValue.category, default: []].contains(where: { $0.id == accountValue.id }) {
                // TODO simplify if condition
                // only display a add button if we are not currently adding a new value for it
                Button(action: {
                    addDetail(for: accountValue)
                }) {
                    Text("Add \(accountValue.name)") // TODO localize
                }
                    .deleteDisabled(true)
            }
        } else {
            if let view = accountValue.dataDisplayViewWithCurrentStoredValue(from: accountDetails) {
                HStack {
                    view
                }
                    .deleteDisabled(true)
            }
        }
    }


    private func cancelAction() {
        if modifiedDetailsBuilder.isEmpty {
            discardChangesAction()
            return
        }

        presentingCancellationDialog = true

        logger.debug("Found \(modifiedDetailsBuilder.count) modified elements. Asking to discard.")
    }

    private func discardChangesAction() {
        logger.debug("Exciting edit mode and discarding changes.")

        resetState()
    }

    private func addDetail(for value: any AccountValueKey.Type) {
        logger.debug("Adding new account value \(value) to the edit view!")

        addedAccountValues[value.category, default: []]
            .append(value) // TODO prevent double clicks?
    }

    private func onEditModeChange(newValue: EditMode?) {
        guard newValue == .inactive,
              viewState != .processing else {
            return
        }

        guard !modifiedDetailsBuilder.isEmpty else {
            logger.debug("Not saving anything, as there is were no changes!")
            return
        }

        logger.debug("Exciting edit mode and saving \(modifiedDetailsBuilder.count) changes to AccountService!")

        withAnimation(.easeOut(duration: 0.2)) {
            viewState = .processing
        }

        actionTask = Task {
            do {
                // TODO do all the visual debounce like AsyncButton?

                if validateInputs() {
                    try await service.updateAccountDetails(modifiedDetailsBuilder.build())
                    logger.debug("\(modifiedDetailsBuilder.count) items saved successfully.")

                    resetState() // this reset the edit mode
                } else {
                    logger.debug("Some input validation failed. Staying in edit mode!")
                }

                withAnimation(.easeIn(duration: 0.2)) {
                    viewState = .idle
                }
            } catch {
                viewState = .error(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: "ACCOUNT_OVERVIEW_EDIT_DEFAULT_ERROR".localized(.module)
                ))
            }
        }
    }

    private func validateInputs() -> Bool {
        // TODO this is a 1:1 code copy!
        let failedFields: [String] = validationClosures.compactMap { entry in
            let result = entry.validationClosure()
            switch result {
            case .success:
                return nil
            case .failed:
                return entry.focusStateValue
            case let .failedAtField(focusedField):
                return focusedField
            }
        }

        if let failedField = failedFields.first {
            focusedDataEntry = failedField
            return false
        }

        focusedDataEntry = nil
        return true
    }

    private func resetState() {
        // clearing the builder before switching the edit mode
        modifiedDetailsBuilder.clear() // it's okay that this doesn't trigger a UI update
        addedAccountValues = [:]

        editMode?.wrappedValue = .inactive
        validationClosures = DataEntryValidationClosures()
    }

    /// Computes if a given `Section` is empty. This is the case if we are **not** currently editing
    /// and the accountDetails don't have values stored for any of the provided ``AccountValueKey``.
    private func sectionIsEmpty(_ accountValues: [any AccountValueKey.Type]) -> Bool {
        guard editMode?.wrappedValue.isEditing == false else {
            // there is always UI presented in EDIT mode
            return false
        }

        // we don't have to check for `addedAccountValues` as these are only relevant in edit mode
        return accountValues.allSatisfy { element in
            !element.isContained(in: accountDetails)
        }
    }
}
