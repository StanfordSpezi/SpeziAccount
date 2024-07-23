//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi

// TODO: remove
import SwiftUI

public protocol ViewProviding {
    @MainActor
    init()
}

@propertyWrapper
public struct ViewProvider<Element: ViewProviding> { // TODO: this is our backup plan for actors!
    @MainActor public var wrappedValue: Element {
        Element()
    }

    public init() {}
}


public struct ServiceViews: ViewProviding {
    @IdentityProviderNEW(placement: .embedded) private var testButton = UserIdPasswordEmbeddedView { credential in
        // TODO: cannot get self
        print("Login \(credential)")
    } signup: {
        NavigationStack {
            Text("Signup View")
        }
    } passwordReset: {
        Text("Password Reset")
    }

    public init() {}
}


struct MockUserIdPasswordEmbeddedView: View {
    @Environment(MockUserIdPasswordAccountService.self) private var service

    var body: some View {
        UserIdPasswordEmbeddedView { credential in
            try await service.login(userId: credential.userId, password: credential.password)
        } signup: {
            NavigationStack {
                SignupForm { signupDetails in
                    try await service.signUp(signupDetails: signupDetails)
                }
            }
        } passwordReset: {
            NavigationStack {
                UserIdPasswordResetView { userId in
                    try await service.resetPassword(userId: userId)
                }
            }
        }
    }
}


/// A mock implementation of a ``UserIdPasswordAccountService`` that can be used in your SwiftUI Previews.
public final class MockUserIdPasswordAccountService: UserIdPasswordAccountService {
    @Dependency private var account: Account

    @IdentityProviderNEW(placement: .embedded) private var loginView = MockUserIdPasswordEmbeddedView()

    @IdentityProviderNEW(placement: .externalIdentityProvider) private var testButton2 = Button {
        print("AAAH")
    } label: {
        Text("Example Button")
    }
    // TODO: we probably need a way to deactivate these on demand! (e.g., atomic but observable?)

    public let configuration: AccountServiceConfiguration
    @MainActor private var userIdToAccountId: [String: UUID] = [:]



    // TODO: @ViewProvider private var views: ServiceViews // TODO: this might be a concept we can use even in actors?
    // TODO: these modifier make the view automatically @MainActor (funny)!


    /// Create a new userId- and password-based account service.
    /// - Parameter type: The ``UserIdType`` to use for the account service.
    public init(_ type: UserIdType = .emailAddress) {
        self.configuration = AccountServiceConfiguration(name: "Mock AccountService", supportedKeys: .arbitrary) {
            UserIdConfiguration(type: type, keyboardType: type == .emailAddress ? .emailAddress : .default)
            RequiredAccountKeys {
                \.userId
                \.password
            }
        }
    }


    public func login(userId: String, password: String) async throws {
        print("Mock Login: \(userId) \(password)")
        try await Task.sleep(for: .seconds(1))

        let details = AccountDetails.Builder()
            .set(\.accountId, value: userIdToAccountId[userId, default: UUID()].uuidString)
            .set(\.userId, value: userId)
            .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
            .build(owner: self)
        let account = account
        try await account.supplyUserDetails(details)
    }

    public func signUp(signupDetails: SignupDetails) async throws {
        print("Mock Signup: \(signupDetails)")
        try await Task.sleep(for: .seconds(1))

        let id = UUID()
        userIdToAccountId[signupDetails.userId] = id

        let details = AccountDetails.Builder(from: signupDetails)
            .set(\.accountId, value: id.uuidString)
            .remove(\.password)
            .build(owner: self)
        let account = account
        try await account.supplyUserDetails(details)
    }

    public func resetPassword(userId: String) async throws {
        print("Mock ResetPassword: \(userId)")
        try await Task.sleep(for: .seconds(1))
    }

    public func logout() async throws {
        print("Mock Logout")
        try await Task.sleep(for: .seconds(1))
        let account = account
        await account.removeUserDetails()
    }

    public func delete() async throws {
        print("Mock Remove Account")
        try await Task.sleep(for: .seconds(1))
        let account = account
        await account.removeUserDetails()
    }

    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        let account = account
        guard let details = account.details else {
            return
        }

        print("Mock Update: \(modifications)")

        try await Task.sleep(for: .seconds(1))

        let builder = AccountDetails.Builder(from: details)
            .merging(modifications.modifiedDetails, allowOverwrite: true)
            .remove(all: modifications.removedAccountDetails.keys)

        try await account.supplyUserDetails(builder.build(owner: self))
    }
}
