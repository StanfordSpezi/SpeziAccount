//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount


actor WebServiceAccountService: UserIdPasswordAccountService {
    let configuration = AccountServiceConfiguration(name: "OAS", supportedKeys: .arbitrary) {
        RequiredAccountKeys {
            \.userId
            \.password
        }
    }

    func signUp(signupDetails: SignupDetails) async throws {

    }

    func login(userId: String, password: String) async throws {

    }

    func resetPassword(userId: String) async throws {

    }

    func updateAccountDetails(_ modifications: AccountModifications) async throws {

    }

    func logout() async throws {

    }

    func delete() async throws {

    }

    // TODO: auth token valid for 1h!
    //  => refresh token!
}
