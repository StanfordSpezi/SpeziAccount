//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


class TestEmailPasswordAccountService: UserIdPasswordAccountService {
    var configuration: UserIdPasswordServiceConfiguration {
        UserIdPasswordServiceConfiguration(
            name: "TestEmailPasswordAccountService",
            image: Image(systemName: "envelope.circle.fill")
                .symbolRenderingMode(.hierarchical),
            userIdType: .emailAddress,
            userIdField: .emailAddress
        )
    }

    @AccountReference
    var account: Account
    let registeredUser = UserStorage() // simulates the backend

    
    init() {}
    
    
    func login(userId: String, password: String) async throws {
        try await Task.sleep(for: .seconds(2))
        
        guard userId == "lelandstanford@stanford.edu", password == "StanfordRocks123!" else {
            throw MockAccountServiceError.wrongCredentials
        }

        registeredUser.userId = userId
        await updateUser()
    }
    
    func signUp(signupRequest: SignupRequest) async throws {
        try await Task.sleep(for: .seconds(2))
        
        guard signupRequest.userId != "lelandstanford@stanford.edu" else {
            throw MockAccountServiceError.usernameTaken
        }

        registeredUser.userId = signupRequest.userId
        registeredUser.name = signupRequest.name
        registeredUser.gender = signupRequest.genderIdentity
        registeredUser.dateOfBirth = signupRequest.dateOfBrith
        await updateUser()
    }

    func updateUser() async {
        let details = AccountDetails.Builder()
            .add(UserIdAccountValueKey.self, value: registeredUser.userId)
            .add(NameAccountValueKey.self, value: registeredUser.name)
            .add(GenderIdentityAccountValueKey.self, value: registeredUser.gender)
            .add(DateOfBirthAccountValueKey.self, value: registeredUser.dateOfBirth)
            .build(owner: self)

        await account.supplyUserDetails(details)
    }
    
    func resetPassword(userId: String) async throws {
        try await Task.sleep(for: .seconds(2))
    }

    func logout() async throws {
        await account.removeUserDetails()
    }
}
