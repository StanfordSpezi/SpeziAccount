//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziViews
import SwiftUI


private struct MockUserIdPasswordEmbeddedView: View {
    @Environment(MockAccountService.self)
    private var service

    var body: some View {
        AccountSetupProviderView { credential in
            let service = service
            try await service.login(userId: credential.userId, password: credential.password)
        } signup: { signupDetails in
            let service = service
            try await service.signUp(with: signupDetails)
        } resetPassword: { userId in
            let service = service
            try await service.resetPassword(userId: userId)
        }
    }

    nonisolated init() {}
}


private struct AnonymousSignupButton: View {
    private let cardinalRed = Color(red: 140 / 255.0, green: 21 / 255.0, blue: 21 / 255.0)
    private let cardinalRedDark = Color(red: 130 / 255.0, green: 0, blue: 0)

    @Environment(MockAccountService.self)
    private var service
    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        AccountServiceButton("Stanford SUNet", systemImage: "graduationcap.fill") {
            service.signInAnonymously()
        }
            .tint(colorScheme == .light ? cardinalRed : cardinalRedDark)
    }
}


private struct MockSignInWithAppleButton: View {
    @Environment(Account.self)
    private var account

    var body: some View {
        SignInWithAppleButton { request in
            if account.configuration.name?.requirement == .required {
                request.requestedScopes = [.email, .fullName]
            } else {
                request.requestedScopes = [.email]
            }

            request.nonce = "ABCDEF"
        } onCompletion: { result in
            print("Sign in with Apple completed: \(result)")
        }
    }
}


private struct MockSecurityAlert: ViewModifier {
    @Environment(MockAccountService.self)
    private var service

    @State private var isActive = false

    @MainActor var isPresented: Binding<Bool> {
        Binding {
            service.presentingSecurityAlert && isActive
        } set: { newValue in
            service.presentingSecurityAlert = newValue
        }
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                isActive = true
            }
            .onDisappear {
                isActive = false
            }
            .alert("Security Alert", isPresented: isPresented, presenting: service.securityContinuation) { continuation in
                Button("Cancel", role: .cancel) {
                    continuation.resume(with: .failure(MockAccountService.AccountError.cancelled))
                }
                Button("Continue", role: .destructive) {
                    continuation.resume()
                }
            }
    }
}


/// A mock `AccountService` that is useful in SwiftUI Previews.
@MainActor
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

    fileprivate struct UserStorage {
        let accountId: UUID
        var userId: String
        var password: String
        var name: PersonNameComponents?
        var genderIdentity: GenderIdentity?
        var dateOfBirth: Date?

        init( // swiftlint:disable:this function_default_parameter_at_end
            accountId: UUID = UUID(),
            userId: String,
            password: String,
            name: PersonNameComponents? = nil,
            genderIdentity: GenderIdentity? = nil,
            dateOfBirth: Date? = nil
        ) {
            self.accountId = accountId
            self.userId = userId
            self.password = password
            self.name = name
            self.genderIdentity = genderIdentity
            self.dateOfBirth = dateOfBirth
        }
    }

    private static let supportedKeys = AccountKeyCollection {
        \.userId
        \.password
        \.name
        \.genderIdentity
        \.dateOfBirth
    }

    @Application(\.logger)
    private var logger

    @Dependency(Account.self)
    private var account
    @Dependency(AccountNotifications.self)
    private var notifications
    @Dependency(ExternalAccountStorage.self)
    private var externalStorage

    @IdentityProvider(section: .primary)
    private var loginView = MockUserIdPasswordEmbeddedView()
    @IdentityProvider private var testButton2 = AnonymousSignupButton()
    @IdentityProvider(section: .singleSignOn)
    private var signInWithApple = MockSignInWithAppleButton()

    @SecurityRelatedModifier private var securityAlert = MockSecurityAlert()
    @MainActor var presentingSecurityAlert = false
    @MainActor var securityContinuation: CheckedContinuation<Void, Error>?

    public let configuration: AccountServiceConfiguration

    private var userIdToAccountId: [String: UUID] = [:]
    private var registeredUsers: [UUID: UserStorage] = [:]


    /// Create a new userId- and password-based account service.
    /// - Parameter type: The ``UserIdType`` to use for the account service.
    public init(_ type: UserIdConfiguration = .emailAddress, configure configured: ConfiguredIdentityProvider = .all) {
        self.configuration = AccountServiceConfiguration(supportedKeys: .exactly(Self.supportedKeys)) {
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

    public func signInAnonymously() {
        var details = AccountDetails()
        details.accountId = UUID().uuidString
        details.isAnonymous = true
        details.isNewUser = true

        account.supplyUserDetails(details)
    }


    public func login(userId: String, password: String) async throws {
        logger.debug("Trying to login \(userId) with password \(password)")
        try await Task.sleep(for: .milliseconds(500))

        guard let accountId = userIdToAccountId[userId],
              let user = registeredUsers[accountId],
              user.password == password else {
            throw AccountError.wrongCredentials
        }

        try await loadUser(user)
    }

    public func signUp(with signupDetails: AccountDetails) async throws {
        logger.debug("Signing up user account \(signupDetails.userId)")
        try await Task.sleep(for: .milliseconds(500))

        guard userIdToAccountId[signupDetails.userId] == nil else {
            throw AccountError.credentialsTaken
        }

        guard let password = signupDetails.password else {
            throw AccountError.internalError
        }

        let storage = UserStorage(
            userId: signupDetails.userId,
            password: password,
            name: signupDetails.name,
            genderIdentity: signupDetails.genderIdentity,
            dateOfBirth: signupDetails.dateOfBirth
        )

        userIdToAccountId[storage.userId] = storage.accountId
        registeredUsers[storage.accountId] = storage

        var externallyStored = signupDetails
        externallyStored.removeAll(Self.supportedKeys)
        if !externallyStored.isEmpty {
            let externalStorage = externalStorage
            try await externalStorage.requestExternalStorage(of: externallyStored, for: storage.accountId.uuidString)
        }

        try await loadUser(storage, isNew: true)
    }

    public func resetPassword(userId: String) async throws {
        logger.debug("Sending password reset e-mail for \(userId)")
        try await Task.sleep(for: .milliseconds(500))
    }

    public func logout() async throws {
        logger.debug("Logging out user")
        try await Task.sleep(for: .milliseconds(500))
        account.removeUserDetails()
    }

    public func delete() async throws {
        guard let details = account.details else {
            return
        }

        logger.debug("Deleting user account for \(details.userId)")
        try await Task.sleep(for: .milliseconds(500))

        try await withCheckedThrowingContinuation { continuation in
            presentingSecurityAlert = true
            securityContinuation = continuation
        }

        let notifications = notifications
        try await notifications.reportEvent(.deletingAccount(details.accountId))

        guard let accountId = UUID(uuidString: details.accountId) else {
            preconditionFailure("Invalid accountId format \(details.accountId)")
        }
        registeredUsers.removeValue(forKey: accountId)
        userIdToAccountId.removeValue(forKey: details.userId)

        account.removeUserDetails()
    }

    @MainActor
    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        guard let details = account.details else {
            throw AccountError.internalError
        }

        guard let accountId = UUID(uuidString: details.accountId) else {
            preconditionFailure("Invalid accountId format \(details.accountId)")
        }

        guard var storage = registeredUsers[accountId] else {
            throw AccountError.internalError
        }

        logger.debug("Updating user details for \(details.userId): \(String(describing: modifications))")
        try await Task.sleep(for: .milliseconds(500))

        if modifications.modifiedDetails.contains(AccountKeys.userId) || modifications.modifiedDetails.contains(AccountKeys.password) {
            try await withCheckedThrowingContinuation { continuation in
                presentingSecurityAlert = true
                securityContinuation = continuation
            }
        }

        storage.update(modifications)
        registeredUsers[accountId] = storage

        var externalModifications = modifications
        externalModifications.removeModifications(for: Self.supportedKeys)
        if !externalModifications.isEmpty {
            let externalStorage = externalStorage
            try await externalStorage.updateExternalStorage(with: externalModifications, for: accountId.uuidString)
        }

        try await loadUser(storage)
    }


    private func loadUser(_ user: UserStorage, isNew: Bool = false) async throws {
        var details = AccountDetails()
        details.accountId = user.accountId.uuidString
        details.userId = user.userId
        details.name = user.name
        details.genderIdentity = user.genderIdentity
        details.dateOfBirth = user.dateOfBirth

        var unsupportedKeys = account.configuration.keys
        unsupportedKeys.removeAll(Self.supportedKeys)
        if !unsupportedKeys.isEmpty {
            let externalStorage = externalStorage
            let externallyStored = try await externalStorage.retrieveExternalStorage(for: details.accountId, unsupportedKeys)
            details.add(contentsOf: externallyStored)
        }

        account.supplyUserDetails(details)
    }
}


extension MockAccountService {
    public enum AccountError: LocalizedError {
        case credentialsTaken
        case wrongCredentials
        case internalError
        case cancelled


        public var errorDescription: String? {
            switch self {
            case .credentialsTaken:
                return "User Identifier is already taken"
            case .wrongCredentials:
                return "Credentials do not match"
            case .internalError:
                return "Internal Error"
            case .cancelled:
                return "Cancelled"
            }
        }

        public var failureReason: String? {
            errorDescription
        }

        public var recoverySuggestion: String? {
            switch self {
            case .credentialsTaken:
                return "Please provide a different user identifier."
            case .wrongCredentials:
                return "Please ensure that the entered credentials are correct."
            case .internalError:
                return "Something went wrong."
            case .cancelled:
                return "The user cancelled the operation."
            }
        }
    }
}


extension MockAccountService.UserStorage {
    mutating func update(_ modifications: AccountModifications) {
        let modifiedDetails = modifications.modifiedDetails
        let removedKeys = modifications.removedAccountDetails

        if modifiedDetails.contains(AccountKeys.userId) {
            self.userId = modifiedDetails.userId
        }
        self.password = modifiedDetails.password ?? password
        self.name = modifiedDetails.name ?? name
        self.genderIdentity = modifiedDetails.genderIdentity ?? genderIdentity
        self.dateOfBirth = modifiedDetails.dateOfBirth ?? dateOfBirth

        // user Id cannot be removed!

        if removedKeys.name != nil {
            self.name = nil
        }
        if removedKeys.genderIdentity != nil {
            self.genderIdentity = nil
        }
        if removedKeys.dateOfBirth != nil {
            self.dateOfBirth = nil
        }
    }
}
