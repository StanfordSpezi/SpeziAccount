//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziViews
import SwiftUI


struct AccountSections: View {
    private let accountDetails: AccountDetails

    @Environment(\.editMode) private var editMode

    @Binding
    private var viewState: ViewState

    @State private var identity: GenderIdentity = .male
    @State private var birthdate: String = "27.02.1999"

    @EnvironmentObject
    private var account: Account


    private var accountValuesBySections: OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]> {
        // We could also just iterate over the `AccountDetails` and show whatever is present.
        // However, we deliberately don't do that. We have the `.supported` requirement option for such cases.
        // And not doing this allows for modelling "shadow" account values that are present but never shown to the user
        // to manage additional state.

        account.configuration.reduce(into: OrderedDictionary()) { result, requirement in
            guard requirement.anyKey.category != AccountValueCategory.credentials else {
                return
            }
            // TODO we need to handle `Credentials` categories differently!
            //  => assume: UserId will be the only credential that is not about passwords!
            //  => everything else is placed into the `Password & Security` section(?)
            //   => can we do different categories for password and userId?

            result[requirement.anyKey.category, default: []] += [requirement.anyKey]
        }
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
            // if the accountHeadline uses the name, we display the userId as the subheadline
            return accountDetails.userId
        } else if accountDetails.userIdType != .emailAddress,
                  let email = accountDetails.email {
            // otherwise, headline will be the userId. Therfore, we check if the userId is not already
            // displaying the email address. In this case the subheadline will be the email if available
            return email
        }

        return nil
    }


    var body: some View {
        Section {
            HStack {
                Spacer()
                VStack {
                    accountHeader
                }
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

        Section {
            // TODO "Name" if available, folled by userId name!
            NavigationLink("Name, E-Mail Address", value: "True")
            NavigationLink("Password & Security", value: "asdf") // TODO how to extend? password only if password is in signup requirements!
            // Text("Edit Mode Nil: \(String(editMode == nil))")
            // Text("Edit Mode: \(String("\(editMode?.wrappedValue ?? .none)"))")
        }

        // TODO how do we achieve order?
        // TODO how do we deal with values which weren't present yet (optionals) (some add button?)

        sectionsView

        Section("Personal Details") {
            // TODO edit button, replacing this with whatever?
            HStack {
                Text("Date of Birth") // TODO we need the name!
                    .fontWeight(.semibold)
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    Spacer()
                    TextField("Birthdate", text: $birthdate)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.primary)
                } else {
                    Text(birthdate) // TODO we need the data representation
                        .foregroundColor(.secondary)
                }
            } // TODO this all must be able to change when you want to edit this?

            if editMode?.wrappedValue.isEditing == true {
                GenderIdentityPicker($identity)
            } else {
                HStack {
                    Text("Gender Identity")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(identity.localizedStringResource)
                        .foregroundColor(.secondary)
                }
            }
        }
            .animation(nil, value: editMode?.wrappedValue)
            // TODO hide back button? and place a custom one if there may be discarded changes!
            .interactiveDismissDisabled(editMode?.wrappedValue.isEditing ?? false)
            .onChange(of: editMode?.wrappedValue, perform: { newValue in // TODO this is placed multiple times?
                if newValue == .inactive {
                    // TODO control loading indicator of parentview!
                    print("LOADING!")
                    viewState = .processing // TODO reset indicator!
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        viewState = .idle
                    }
                }
                // print("edit mode changed to \(newValue)")
            })
    }

    @ViewBuilder private var accountHeader: some View {
        // we gracefully check if the account details have a name, bypassing the subscript overloads
        if let name = accountDetails.storage.get(PersonNameKey.self) {
            UserProfileView(name: name) // TODO may we support an "image loader"?
                .frame(height: 90) // TODO verify on other devices?
        }

        Text(accountHeadline)
            .font(.title2)
            .fontWeight(.semibold)
            // TODO toolbar placement!
            .toolbar {
                if editMode?.wrappedValue.isEditing == true {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: { print("cancel") }) {
                            Text("Cancel")
                        }
                    }
                }
            }

        if let accountSubheadline {
            Text(accountSubheadline)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder private var sectionsView: some View {
        ForEach(accountValuesBySections.elements, id: \.key) { category, accountValues in
            Section {
                Text("This is the section")
            } header: {
                if let title = category.categoryTitle {
                    Text(title)
                } else {
                    EmptyView()
                }
            }
        }
    }


    init(details account: AccountDetails, state viewState: Binding<ViewState>) {
        self.accountDetails = account
        self._viewState = viewState
    }
}


public struct AccountOverview: View {
    @EnvironmentObject private var account: Account

    @State private var viewState: ViewState = .idle


    public var body: some View {
        if let details = account.details {
            Form {
                AccountSections(details: details, state: $viewState)

                // UserInformation(name: account.name, caption: account.userId)
            }
                .viewStateAlert(state: $viewState)
                .toolbar {

                    ToolbarItemGroup(placement: .primaryAction) {
                        EditButton()
                            .processingOverlay(isProcessing: viewState)
                    }
                    // TODO warn discarding changes when pressin back button
                    //  => hide back button and place a cancel button!
                }
                .padding(.top, -20)
        } else {
            // TODO handle
            Text("No active Account!")
        }
    }

    public init() {}
}


#if DEBUG
struct AccountOverView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", middleName: "Michael", familyName: "Bauer"))

    static var previews: some View {
        NavigationStack {
            AccountOverview()
                .environmentObject(Account(building: details, active: MockUsernamePasswordAccountService()))
        }
    }
}
#endif
