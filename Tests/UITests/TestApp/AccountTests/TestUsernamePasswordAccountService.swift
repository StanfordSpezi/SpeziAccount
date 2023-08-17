//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount


actor TestUsernamePasswordAccountService: UserIdPasswordAccountService {
    nonisolated let configuration = AccountServiceConfiguration(name: "TestUsernamePasswordAccountService") {
        UserIdConfiguration(type: .username)
    }

    @AccountReference var account: Account
    var registeredUser = UserStorage() // simulates the backend

    init() {}

    func login(userId: String, password: String) async throws {
        try await Task.sleep(for: .seconds(2))

        guard userId == "lelandstanford", password == "StanfordRocks123!" else {
            throw MockAccountServiceError.wrongCredentials
        }

        registeredUser.userId = userId
        await updateUser()
    }

    func signUp(signupDetails: SignupDetails) async throws {
        try await Task.sleep(for: .seconds(2))

        guard signupDetails.userId != "lelandstanford" else {
            throw MockAccountServiceError.usernameTaken
        }

        registeredUser.userId = signupDetails.userId
        registeredUser.name = signupDetails.name
        registeredUser.gender = signupDetails.genderIdentity
        registeredUser.dateOfBirth = signupDetails.dateOfBrith
        await updateUser()
    }

    func updateAccountDetails(_ modifications: AccountModifications) async throws {
        // TODO implement!
    }

    func updateUser() async {
        let details = AccountDetails.Builder()
            .set(\.userId, value: registeredUser.userId)
            .set(\.name, value: registeredUser.name)
            .set(\.genderIdentity, value: registeredUser.gender)
            .set(\.dateOfBirth, value: registeredUser.dateOfBirth)
            .build(owner: self)

        await account.supplyUserDetails(details)
    }

    func resetPassword(userId: String) async throws {
        try await Task.sleep(for: .seconds(2))
    }

    func logout() async throws {
        await account.removeUserDetails()
    }

    func delete() async throws {
        await account.removeUserDetails()
        registeredUser = UserStorage()
    }
}
