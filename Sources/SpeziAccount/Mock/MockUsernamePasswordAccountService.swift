//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO docs!
public actor MockUsernamePasswordAccountService: UserIdPasswordAccountService {
    @AccountReference private var account: Account


    public let configuration = AccountServiceConfiguration(name: "Mock AccountService")


    public func login(userId: String, password: String) async throws {
        print("Mock Login: \(userId) \(password)")
        try? await Task.sleep(for: .seconds(1))

        let details = AccountDetails.Builder()
            .add(\.userId, value: userId)
            .add(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
            .build(owner: self)
        await account.supplyUserDetails(details)
    }

    public func signUp(signupRequest: SignupRequest) async throws {
        print("Mock Signup: \(signupRequest)")
        try? await Task.sleep(for: .seconds(1))

        let details = AccountDetails.Builder(from: signupRequest)
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
}
