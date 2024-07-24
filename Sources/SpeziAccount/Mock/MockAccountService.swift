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

// TODO: remove
import SwiftUI

public protocol ViewProviding {
    @MainActor
    init()
}

@propertyWrapper
public struct ViewProvider<Element: ViewProviding> { // TODO: this is our backup plan for actors!
    @MainActor public var wrappedValue: Element {
        Element()
    }

    public init() {}
}


public struct ServiceViews: ViewProviding {
    @IdentityProvider(placement: .embedded) private var testButton = EmptyView()

    public init() {}
}


struct MockUserIdPasswordEmbeddedView: View {
    @Environment(MockAccountService.self) private var service

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

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        AccountServiceButton("Stanford SUNet", systemImage: "graduationcap.fill") {
            print("Pressed SUNet Account Service")
        }
            .tint(colorScheme == .light ? cardinalRed : cardinalRedDark)
    }
}


struct MockSignInWithAppleButton: View { // TODO: rename, redo (actually test that in the simulator?)
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


/// A mock implementation of a ``UserIdPasswordAccountService`` that can be used in your SwiftUI Previews.
@MainActor // TODO: review
public final class MockAccountService: AccountService {
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

    @IdentityProvider(placement: .embedded) private var loginView = MockUserIdPasswordEmbeddedView()
    @IdentityProvider private var testButton2 = CustomServiceButton()
    @IdentityProvider(placement: .external) private var signInWithApple = MockSignInWithAppleButton()

    // TODO: @SecurityRelatedModifier private var securityAlert = NoopModifier()

    public let configuration: AccountServiceConfiguration
    private var userIdToAccountId: [String: UUID] = [:]


    // TODO: @ViewProvider private var views: ServiceViews // TODO: this might be a concept we can use even in actors?
    // TODO: these modifier make the view automatically @MainActor (funny)!


    /// Create a new userId- and password-based account service.
    /// - Parameter type: The ``UserIdType`` to use for the account service.
    public init(_ type: UserIdType = .emailAddress, configure configured: ConfiguredIdentityProvider = .all) {
        self.configuration = AccountServiceConfiguration(supportedKeys: .arbitrary) {
            UserIdConfiguration(type: type, keyboardType: type == .emailAddress ? .emailAddress : .default)
            RequiredAccountKeys {
                \.userId
                \.password
            }
        }

        // TODO: this is a problem with actor isolation?
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

        let details = AccountDetails.Builder()
            .set(\.accountId, value: userIdToAccountId[userId, default: UUID()].uuidString)
            .set(\.userId, value: userId)
            .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
            .build(owner: self)
        let account = account
        try await account.supplyUserDetails(details)
    }

    public func signUp(signupDetails: SignupDetails) async throws {
        print("Mock Signup: \(signupDetails)")
        try await Task.sleep(for: .seconds(1))

        let id = UUID()
        userIdToAccountId[signupDetails.userId] = id

        let details = AccountDetails.Builder(from: signupDetails)
            .set(\.accountId, value: id.uuidString)
            .remove(\.password)
            .build(owner: self)
        let account = account
        try await account.supplyUserDetails(details)
    }

    public func resetPassword(userId: String) async throws {
        print("Mock ResetPassword: \(userId)")
        try await Task.sleep(for: .seconds(1))
    }

    public func logout() async throws {
        print("Mock Logout")
        try await Task.sleep(for: .seconds(1))
        let account = account
        await account.removeUserDetails()
    }

    public func delete() async throws {
        print("Mock Remove Account")
        try await Task.sleep(for: .seconds(1))
        let account = account
        await account.removeUserDetails()
    }

    @MainActor
    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        let account = account
        guard let details = account.details else {
            return
        }

        print("Mock Update: \(modifications)")

        try await Task.sleep(for: .seconds(1))

        let builder = AccountDetails.Builder(from: details)
            .merging(modifications.modifiedDetails, allowOverwrite: true)
            .remove(all: modifications.removedAccountDetails.keys)

        try await account.supplyUserDetails(builder.build(owner: self))
    }
}
