//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO docs! rename UserId => make userid type controlable!
public actor MockUsernamePasswordAccountService: UserIdPasswordAccountService {
    @AccountReference private var account: Account


    public let configuration = AccountServiceConfiguration(name: "Mock AccountService")

    public init() {}

    public func login(userId: String, password: String) async throws {
        print("Mock Login: \(userId) \(password)")
        try? await Task.sleep(for: .seconds(1))

        let details = AccountDetails.Builder()
            .set(\.userId, value: userId)
            .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
            .build(owner: self)
        await account.supplyUserDetails(details)
    }

    public func signUp(signupDetails: SignupDetails) async throws {
        print("Mock Signup: \(signupDetails)")
        try? await Task.sleep(for: .seconds(1))

        let details = AccountDetails.Builder(from: signupDetails)
            .remove(\.password)
            .build(owner: self)
        await account.supplyUserDetails(details)
    }

    public func resetPassword(userId: String) async throws {
        print("Mock ResetPassword: \(userId)")
        try? await Task.sleep(for: .seconds(1))
    }

    public func logout() async throws {
        print("Mock Logout")
        try? await Task.sleep(for: .seconds(1))
        await account.removeUserDetails()
    }

    public func remove() async throws {
        print("Mock Remove Account")
        try? await Task.sleep(for: .seconds(1))
        await account.removeUserDetails()
    }

    public func updateAccountDetails(_ details: ModifiedAccountDetails) async throws {
        // TODO update the previous details!
    }
}
