//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount


class MockEmailPasswordAccountService: EmailPasswordAccountService {
    let user: User
    // TODO transform!
    
    init(user: User) {
        self.user = user
    }
    
    
    override func login(username: String, password: String) async throws {
        try await Task.sleep(for: .seconds(5))
        
        guard username == "lelandstanford@stanford.edu", password == "StanfordRocks123!" else {
            throw MockAccountServiceError.wrongCredentials
        }
        
        await MainActor.run {
            account?.signedIn = true
            user.userId = username
        }
    }
    
    override func signUp(signUpValues: SignUpValues) async throws {
        try await Task.sleep(for: .seconds(5))
        
        guard signUpValues.userId != "lelandstanford@stanford.edu" else {
            throw MockAccountServiceError.usernameTaken
        }
        
        await MainActor.run {
            account?.signedIn = true
            user.userId = signUpValues.userId
            user.name = signUpValues.name
            user.dateOfBirth = signUpValues.dateOfBirth
            user.gender = signUpValues.genderIdentity
        }
    }
    
    override func resetPassword(username: String) async throws {
        try await Task.sleep(for: .seconds(5))
    }
}
