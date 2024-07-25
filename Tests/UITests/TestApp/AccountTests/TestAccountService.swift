//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AuthenticationServices
import Spezi
import SpeziAccount
import SwiftUI


private struct EmbeddedView: View {
    @Environment(TestAccountService.self) private var service

    var body: some View {
        UserIdPasswordEmbeddedView { credential in
            let service = service
            try await service.login(userId: credential.userId, password: credential.password)
        } signup: { signupDetails in
            let service = service
            try await service.signUp(signupDetails: signupDetails)
        } resetPassword: { userId in
            let service = service
            try await service.resetPassword(userId: userId)
        }
    }

    nonisolated init() {}
}

private struct CustomServiceButton: View {
    var body: some View {
        AccountServiceButton("OpenID Connect", systemImage: "o.circle") {
            print("Pressed Account Service")
        }
            .tint(Color(red: 235/255.0, green: 124/255.0, blue: 4/255.0))
    }
}


private struct MockSignInWithAppleButton: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        SignInWithAppleButton { _ in
            // request
        } onCompletion: { _ in
            // result
        }
            .frame(height: 55)
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
    }
}


@MainActor
final class TestAccountService: AccountService { // TODO: just use the MockAccountService? we duplicate a lot!
    nonisolated let configuration: AccountServiceConfiguration

    private let defaultUserId: String
    private let defaultAccountOnConfigure: Bool
    private var excludeName: Bool

    var registeredUser: UserStorage // simulates the backend

    @Dependency var account: Account
    @Model var model = TestAlertModel()

    @IdentityProvider(placement: .primary) private var loginView = EmbeddedView()
    @IdentityProvider(enabled: false) private var customProvider = CustomServiceButton()
    @IdentityProvider(enabled: false, placement: .external) private var signInWithApple = MockSignInWithAppleButton()

    @SecurityRelatedModifier private var testAlert = TestAlertModifier()

    init(_ type: UserIdType, features: Features) {
        configuration = AccountServiceConfiguration(supportedKeys: .exactly(UserStorage.supportedKeys)) {
            RequiredAccountKeys {
                \.userId
                \.password
            }
            UserIdConfiguration(type: type, keyboardType: type == .emailAddress ? .emailAddress : .default)
        }

        self.defaultUserId = type == .emailAddress ? UserStorage.defaultEmail : UserStorage.defaultUsername
        self.defaultAccountOnConfigure = features.defaultCredentials
        self.excludeName = features.noName
        self.registeredUser = UserStorage(userId: defaultUserId)

        switch features.serviceType {
        case .mail:
            break
        case .both:
            $customProvider.isEnabled = true
        case .withIdentityProvider:
            $signInWithApple.isEnabled = true
        case .empty:
            $loginView.isEnabled = false
        }
    }

    @MainActor
    func configure() {
        if defaultAccountOnConfigure {
            Task { @MainActor in
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
        if modifications.modifiedDetails.storage.get(UserIdKey.self) != nil
            || modifications.modifiedDetails.storage.get(PasswordKey.self) != nil {
            await withCheckedContinuation { continuation in
                model.presentingAlert = true
                model.continuation = continuation
            }
        } else {
            try await Task.sleep(for: .seconds(1))
        }

        registeredUser.update(modifications)

        try await updateUser()
    }

    func updateUser() async throws {
        let details: AccountDetails = .build { details in
            details.accountId = registeredUser.accountId.uuidString
            details.userId = registeredUser.userId
            details.genderIdentity = registeredUser.genderIdentity
            details.dateOfBirth = registeredUser.dateOfBirth
            details.biography = registeredUser.biography

            if !excludeName {
                details.name = registeredUser.name
            } else {
                excludeName = false // reset
            }
        }

        let account = account
        try await account.supplyUserDetails(details)
    }

    func resetPassword(userId: String) async throws {
        try await Task.sleep(for: .seconds(2))
    }

    func logout() async throws {
        let account = account
        await account.removeUserDetails()
    }

    func delete() async throws {
        let account = account
        await account.removeUserDetails()
        registeredUser = UserStorage(userId: defaultUserId)
    }
}
