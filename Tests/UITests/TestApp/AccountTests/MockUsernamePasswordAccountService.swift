//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CardinalKitAccount


class MockUsernamePasswordAccountService: UsernamePasswordAccountService {
    let user: User
    
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    
    override func login(username: String, password: String) async throws {
        try await Task.sleep(for: .seconds(5))
        
        guard username == "lelandstanford", password == "StanfordRocks123!" else {
            throw MockAccountServiceError.wrongCredentials
        }
        
        await MainActor.run {
            account?.signedIn = true
            user.username = username
        }
    }
    
    
    override func signUp(signUpValues: SignUpValues) async throws {
        try await Task.sleep(for: .seconds(5))
        
        guard signUpValues.username != "lelandstanford" else {
            throw MockAccountServiceError.usernameTaken
        }
        
        await MainActor.run {
            account?.signedIn = true
            user.username = signUpValues.username
            user.name = signUpValues.name
            user.dateOfBirth = signUpValues.dateOfBirth
            user.gender = signUpValues.genderIdentity
        }
    }
    
    override func resetPassword(username: String) async throws {
        try await Task.sleep(for: .seconds(5))
    }
}
