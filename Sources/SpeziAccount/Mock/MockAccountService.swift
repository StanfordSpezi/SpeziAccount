//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AuthenticationServices
import Foundation
import Spezi
import SwiftUI


struct MockUserIdPasswordEmbeddedView: View {
    @Environment(MockAccountService.self)
    private var service

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


struct CustomServiceButton: View {
    private let cardinalRed = Color(red: 140 / 255.0, green: 21 / 255.0, blue: 21 / 255.0)
    private let cardinalRedDark = Color(red: 130 / 255.0, green: 0, blue: 0)

    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        AccountServiceButton("Stanford SUNet", systemImage: "graduationcap.fill") {
            print("Pressed SUNet Account Service")
        }
            .tint(colorScheme == .light ? cardinalRed : cardinalRedDark)
    }
}


struct MockSignInWithAppleButton: View { // TODO: rename, redo (actually test that in the simulator?)
    @Environment(\.colorScheme)
    private var colorScheme

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


/// A mock implementation of a ``UserIdPasswordAccountService`` that can be used in your SwiftUI Previews.
@MainActor
public final class MockAccountService: AccountService { // TODO: just write an feature complete in memory account service we can use also in tests!
    public struct ConfiguredIdentityProvider: OptionSet, Sendable {
        public static let userIdPassword = ConfiguredIdentityProvider(rawValue: 1 << 0)
        public static let customIdentityProvider = ConfiguredIdentityProvider(rawValue: 1 << 1)
        public static let signInWithApple = ConfiguredIdentityProvider(rawValue: 1 << 2)
        public static let all: ConfiguredIdentityProvider = [.userIdPassword, .customIdentityProvider, .signInWithApple]

        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    @Dependency private var account: Account
    @Dependency private var notifications: AccountNotifications
    @Dependency private var externalStorage: ExternalAccountStorage

    @IdentityProvider(section: .primary)
    private var loginView = MockUserIdPasswordEmbeddedView()
    @IdentityProvider private var testButton2 = CustomServiceButton() // TODO: anonymous login?
    @IdentityProvider(section: .singleSignOn)
    private var signInWithApple = MockSignInWithAppleButton()

    // TODO: @SecurityRelatedModifier private var securityAlert = NoopModifier()

    public let configuration: AccountServiceConfiguration
    private var userIdToAccountId: [String: UUID] = [:]


    /// Create a new userId- and password-based account service.
    /// - Parameter type: The ``UserIdType`` to use for the account service.
    public init(_ type: UserIdConfiguration = .emailAddress, configure configured: ConfiguredIdentityProvider = .all) {
        self.configuration = AccountServiceConfiguration(supportedKeys: .arbitrary) {
            type
            RequiredAccountKeys {
                \.userId
                \.password
            }
        }

        if !configured.contains(.userIdPassword) {
            $loginView.isEnabled = false
        }
        if !configured.contains(.customIdentityProvider) {
            $testButton2.isEnabled = false
        }
        if !configured.contains(.signInWithApple) {
            $signInWithApple.isEnabled = false
        }
    }


    public func login(userId: String, password: String) async throws {
        print("Mock Login: \(userId) \(password)")
        try await Task.sleep(for: .seconds(1))

        let accountId = userIdToAccountId[userId, default: UUID()].uuidString

        var details = AccountDetails()
        details.accountId = accountId
        details.userId = userId
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

        let externalStorage = externalStorage
        let externallyStored = try await externalStorage.retrieveExternalStorage(for: accountId, []) // TODO: keys!
        details.add(contentsOf: externallyStored)

        let account = account
        account.supplyUserDetails(details)
    }

    public func signUp(signupDetails: AccountDetails) async throws {
        print("Mock Signup: \(signupDetails)")
        try await Task.sleep(for: .seconds(1))

        let id = UUID()
        userIdToAccountId[signupDetails.userId] = id

        var details = AccountDetails()
        details.add(contentsOf: signupDetails)
        details.accountId = id.uuidString
        details.password = nil // make sure we don't store the plaintext password

        // TODO: simulate external storage?

        let account = account
        account.supplyUserDetails(details)
    }

    public func resetPassword(userId: String) async throws {
        print("Mock ResetPassword: \(userId)")
        try await Task.sleep(for: .seconds(1))
    }

    public func logout() async throws {
        print("Mock Logout")
        try await Task.sleep(for: .seconds(1))
        let account = account
        account.removeUserDetails()
    }

    public func delete() async throws {
        guard let details = account.details else {
            return
        }
        print("Mock Remove Account")

        let notifications = notifications
        try await notifications.reportEvent(.deletingAccount(details.accountId))

        try await Task.sleep(for: .seconds(1))
        let account = account
        account.removeUserDetails()
    }

    @MainActor
    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        let account = account
        guard let currentDetails = account.details else {
            return
        }

        print("Mock Update: \(modifications)")

        try await Task.sleep(for: .seconds(1))

        var updatedDetails = AccountDetails()
        updatedDetails.add(contentsOf: currentDetails)
        updatedDetails.add(contentsOf: modifications.modifiedDetails, merge: true)
        updatedDetails.removeAll(modifications.removedAccountKeys)

        // TODO: split out and notify external storage!
        account.supplyUserDetails(updatedDetails)
    }
}
