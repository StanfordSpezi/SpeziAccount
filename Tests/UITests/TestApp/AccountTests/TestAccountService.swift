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
    private let defaultAccountOnConfigure: Bool
    private var excludeName: Bool

    @AccountReference var account: Account
    var registeredUser: UserStorage // simulates the backend


    init(_ type: UserIdType, defaultAccount: Bool = false, noName: Bool = false) {
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
        self.defaultAccountOnConfigure = defaultAccount
        self.excludeName = noName
        registeredUser = UserStorage(userId: defaultUserId)
    }

    nonisolated func configure() {
        if defaultAccountOnConfigure {
            Task {
                do {
                    try await updateUser()
                } catch {
                    print("Failed to set default user: \(error)")
                }
            }
        }
    }


    func login(userId: String, password: String) async throws {
        try await Task.sleep(for: .seconds(1))

        guard userId == registeredUser.userId && password == registeredUser.password else {
            throw MockAccountServiceError.wrongCredentials
        }

        registeredUser.userId = userId
        try await updateUser()
    }

    func signUp(signupDetails: SignupDetails) async throws {
        try await Task.sleep(for: .seconds(1))

        guard signupDetails.userId != registeredUser.userId else {
            throw MockAccountServiceError.credentialsTaken
        }

        registeredUser.userId = signupDetails.userId
        registeredUser.name = signupDetails.name
        registeredUser.genderIdentity = signupDetails.genderIdentity
        registeredUser.dateOfBirth = signupDetails.dateOfBrith
        try await updateUser()
    }

    func updateAccountDetails(_ modifications: AccountModifications) async throws {
        try await Task.sleep(for: .seconds(1))
        registeredUser.update(modifications)

        try await updateUser()
    }

    func updateUser() async throws {
        let builder = AccountDetails.Builder()
            .set(\.accountId, value: registeredUser.accountId.uuidString)
            .set(\.userId, value: registeredUser.userId)
            .set(\.genderIdentity, value: registeredUser.genderIdentity)
            .set(\.dateOfBirth, value: registeredUser.dateOfBirth)
            .set(\.biography, value: registeredUser.biography)

        if !self.excludeName {
            builder.set(\.name, value: registeredUser.name)
        } else {
            excludeName = false
        }

        let details = builder
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
