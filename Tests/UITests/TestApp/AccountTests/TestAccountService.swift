//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount


actor TestAccountService: UserIdPasswordAccountService {
    nonisolated let configuration: AccountServiceConfiguration
    private let defaultUserId: String

    @AccountReference var account: Account
    var registeredUser: UserStorage // simulates the backend


    init(_ type: UserIdType) {
        configuration = AccountServiceConfiguration(
            name: "\(type.localizedStringResource) and Password",
            supportedKeys: .exactly(UserStorage.supportedKeys)
        ) {
            RequiredAccountKeys {
                \.userId
                \.password
            }
            UserIdConfiguration(type: type, keyboardType: type == .emailAddress ? .emailAddress : .default)
        }

        defaultUserId = type == .emailAddress ? UserStorage.defaultEmail : UserStorage.defaultUsername
        registeredUser = UserStorage(userId: defaultUserId)
    }


    func login(userId: String, password: String) async throws {
        try await Task.sleep(for: .seconds(2))

        guard userId == registeredUser.userId && password == registeredUser.password else {
            throw MockAccountServiceError.wrongCredentials
        }

        registeredUser.userId = userId
        try await updateUser()
    }

    func signUp(signupDetails: SignupDetails) async throws {
        try await Task.sleep(for: .seconds(2))

        guard signupDetails.userId != registeredUser.userId else {
            throw MockAccountServiceError.usernameTaken
        }

        registeredUser.userId = signupDetails.userId
        registeredUser.name = signupDetails.name
        registeredUser.genderIdentity = signupDetails.genderIdentity
        registeredUser.dateOfBirth = signupDetails.dateOfBrith
        try await updateUser()
    }

    func updateAccountDetails(_ modifications: AccountModifications) async throws {
        registeredUser.update(modifications)
    }

    func updateUser() async throws {
        let details = AccountDetails.Builder()
            .set(\.userId, value: registeredUser.userId)
            .set(\.name, value: registeredUser.name)
            .set(\.genderIdentity, value: registeredUser.genderIdentity)
            .set(\.dateOfBirth, value: registeredUser.dateOfBirth)
            .build(owner: self)

        try await account.supplyUserDetails(details)
    }

    func resetPassword(userId: String) async throws {
        try await Task.sleep(for: .seconds(2))
    }

    func logout() async throws {
        await account.removeUserDetails()
    }

    func delete() async throws {
        await account.removeUserDetails()
        registeredUser = UserStorage(userId: defaultUserId)
    }
}
