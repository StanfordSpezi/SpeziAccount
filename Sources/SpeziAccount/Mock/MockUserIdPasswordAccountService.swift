//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A mock implementation of a ``UserIdPasswordAccountService`` that can be used in your SwiftUI Previews.
public actor MockUserIdPasswordAccountService: UserIdPasswordAccountService {
    @AccountReference private var account: Account

    public let configuration: AccountServiceConfiguration
    private var userIdToAccountId: [String: UUID] = [:]


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
        guard let details = await account.details else {
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
