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


// TODO generalize to data entry build or something (or just account value builder?)
class SignupRequestBuilder: ObservableObject {
    @Published var storage = AccountValueStorage()

    // TODO this is basically like a SignupRequest builder!

    public func post<Key: AccountValueKey>(for key: Key.Type, value: Key.Value) {
        storage[Key.self] = value
    }
}


public struct SignupForm<Service: AccountService, Header: View>: View {
    private let service: Service
    private let header: Header

    @EnvironmentObject
    private var account: Account

    // TODO use a private type for this, such that it is inaccessible by the sub views
    @StateObject
    private var signupRequestBuilder = SignupRequestBuilder()
    // We just use @State here for the class type, as there is nothing in it that triggers a UI update.
    // However, we need to preserve the class state across UI updates.
    @State
    private var validationClosures = DataEntryValidationClosures()

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String? // see `AccountValueKey.Type/focusState`


    private var signupRequirements: AccountValueRequirements {
        // TODO this should be account.signupRequirements or the requirements the AccountService supports??
        //  => generally we shouldn't collect more than the user wants; but AccountService has to deal with less being collected than it could!
        account.signupRequirements
    }

    private var signupValuesBySections: OrderedDictionary<SignupCategory, [any AccountValueKey.Type]> {
        signupRequirements.reduce(into: [:]) { result, requirement in
            result[requirement.anyKey.signupCategory, default: []] += [requirement.anyKey]
        }
    }

    private var dataEntryConfiguration: DataEntryConfiguration {
        // only call this computed property from within the view's body
        .init(configuration: service.configuration, validationClosures: validationClosures, focusedField: _focusedDataEntry, viewState: $viewState)
    }


    public var body: some View {
        form
            .navigationTitle("Signup") // TODO localize!
            .disableDismissiveActions(isProcessing: viewState)
            .viewStateAlert(state: $viewState)
            .onTapGesture {
                focusedDataEntry = nil
            }
    }

    @ViewBuilder
    var sectionsView: some View {
        // OrderedDictionary `elements` conforms to RandomAccessCollection so we can directly use it
        ForEach(signupValuesBySections.elements, id: \.key) { category, accountValues in
            Section {
                // the array doesn't change, so its fine to rely on the indices as identifiers
                ForEach(accountValues.indices, id: \.self) { index in
                    accountValues[index].anyDataEntryView
                }
            } header: {
                if let title = category.categoryTitle {
                    Text(title)
                } else {
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    var form: some View {
        Form {
            header

            sectionsView
                .environment(\.dataEntryConfiguration, dataEntryConfiguration)
                .environmentObject(signupRequestBuilder)

            AsyncButton(state: $viewState, action: signupButtonAction) {
                Text("UP_SIGNUP".localized(.module))
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
        }
            .environment(\.defaultErrorDescription, .init("UP_SIGNUP_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
    }


    init(using service: Service) where Header == Text {
        self.service = service
        self.header = Text("UP_SIGNUP_INSTRUCTIONS".localized(.module))
    }

    init(service: Service, @ViewBuilder header: () -> Header) {
        self.service = service
        self.header = header()
    }


    private func signupButtonAction() async throws {
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
            return
        }

        focusedDataEntry = nil

        // TODO is the account values builder still necessary?
        let builder = SignupRequest.Builder(from: signupRequestBuilder.storage) // TODO review!

        // TODO verify against which requirements we are checking!
        let request: SignupRequest = try builder.build(checking: signupRequirements)

        try await service.signUp(signupRequest: request)
        // TODO do we impose any requirements, that there should a logged in user after this?

        // TODO navigate back if the encapsulating view doesn't do anything!
    }
}

extension AccountValueKey {
    fileprivate static var anyDataEntryView: AnyView {
        AnyView(dataEntryView)
    }
}


#if DEBUG
struct DefaultUserIdPasswordSignUpView_Previews: PreviewProvider {
    static let accountService = MockUsernamePasswordAccountService()

    static var previews: some View {
        NavigationStack {
            SignupForm(using: accountService)
        }
            .environmentObject(Account(accountService))
    }
}
#endif
