//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziFoundation
import SpeziViews
import SwiftUI


private struct MockUserIdPasswordEmbeddedView: View {
    @Environment(InMemoryAccountService.self)
    private var service

    var body: some View {
        AccountSetupProviderView { credential in
            try await service.login(userId: credential.userId, password: credential.password)
        } signup: { signupDetails in
            try await service.signUp(with: signupDetails)
        } resetPassword: { userId in
            try await service.resetPassword(userId: userId)
        }
    }

    nonisolated init() {}
}


private struct AnonymousSignupButton: View {
    private let cardinalRed = Color(red: 140 / 255.0, green: 21 / 255.0, blue: 21 / 255.0)
    private let cardinalRedDark = Color(red: 130 / 255.0, green: 0, blue: 0)

    @Environment(InMemoryAccountService.self)
    private var service
    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        AccountServiceButton {
            service.signInAnonymously()
        } label: {
            Label {
                Text(verbatim: "Stanford SUNet")
            } icon: {
                Image(systemName: "graduationcap.fill") // swiftlint:disable:this accessibility_label_for_image
            }
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
            .frame(height: 55)
    }
}


private struct MockSecurityAlert: ViewModifier {
    @Environment(InMemoryAccountService.self)
    private var service

    @State private var isActive = false

    @MainActor var isPresented: Binding<Bool> {
        Binding {
            service.state.presentingSecurityAlert && isActive
        } set: { newValue in
            service.state.presentingSecurityAlert = newValue
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
            .alert(Text(verbatim: "Security Alert"), isPresented: isPresented, presenting: service.state.securityContinuation) { continuation in
                Button(role: .cancel) {
                    continuation.resume(with: .failure(InMemoryAccountService.AccountError.cancelled))
                } label: {
                    Text(verbatim: "Cancel")
                }
                Button(role: .destructive) {
                    continuation.resume()
                } label: {
                    Text(verbatim: "Continue")
                }
            }
    }
}


/// An Account Service that stores account information in memory.
///
/// This ``AccountService`` implements an account service that stores user data in memory.
/// It serves as an example implementation, demonstrating a complete implementation of an `AccountService`.
/// Further, it can be easily integrated in SwiftUI previews and UI tests.
@MainActor
public final class InMemoryAccountService: AccountService {
    private static let supportedKeys = AccountKeyCollection {
        \.accountId
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

    public let configuration: AccountServiceConfiguration
    fileprivate let state = State()
    private let access = AsyncSemaphore()

    private var userIdToAccountId: [String: UUID] = [:]
    private var registeredUsers: [UUID: UserStorage] = [:]


    /// Create a new userId- and password-based account service.
    /// - Parameters:
    ///   - type: The ``UserIdType`` to use for the account service.
    ///   - configured: The set of identity providers to enable.
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

    public func configure() {
        let subscription = externalStorage.updatedDetails
        Task { [weak self] in
            for await updatedDetails in subscription {
                guard let self else {
                    return
                }

                guard let accountId = UUID(uuidString: updatedDetails.accountId),
                      let storage = registeredUsers[accountId] else {
                    continue
                }

                try await access.waitCheckingCancellation()
                var details = _buildUser(from: storage, isNew: false)
                details.add(contentsOf: updatedDetails.details)
                account.supplyUserDetails(details)
                access.signal()
            }
        }
    }

    public func signInAnonymously() {
        let id = UUID()

        var details = AccountDetails()
        details.accountId = id.uuidString
        details.isAnonymous = true
        details.isNewUser = true

        registeredUsers[id] = UserStorage(accountId: id, userId: nil, password: nil)
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

        var storage: UserStorage
        if let details = account.details,
           let registered = registeredUsers[details.accountId.assumeUUID] {
            guard details.isAnonymous else {
                throw AccountError.internalError
            }

            // do account linking for anonymous accounts!´
            storage = registered
            storage.userId = signupDetails.userId
            storage.password = password
            if let name = signupDetails.name {
                storage.name = name
            }
            if let genderIdentity = signupDetails.genderIdentity {
                storage.genderIdentity = genderIdentity
            }
            if let dateOfBirth = signupDetails.dateOfBirth {
                storage.dateOfBirth = dateOfBirth
            }
        } else {
            storage = UserStorage(
                userId: signupDetails.userId,
                password: password,
                name: signupDetails.name,
                genderIdentity: signupDetails.genderIdentity,
                dateOfBirth: signupDetails.dateOfBirth
            )
        }

        userIdToAccountId[signupDetails.userId] = storage.accountId
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
            state.presentingSecurityAlert = true
            state.securityContinuation = continuation
        }

        let notifications = notifications
        try await notifications.reportEvent(.deletingAccount(details.accountId))

        registeredUsers.removeValue(forKey: details.accountId.assumeUUID)
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
                state.presentingSecurityAlert = true
                state.securityContinuation = continuation
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
        try await access.waitCheckingCancellation()
        defer {
            access.signal()
        }
        var details = _buildUser(from: user, isNew: isNew)

        var unsupportedKeys = account.configuration.keys
        unsupportedKeys.removeAll(Self.supportedKeys)
        if !unsupportedKeys.isEmpty {
            let externalStorage = externalStorage
            let externallyStored = await externalStorage.retrieveExternalStorage(for: user.accountId.uuidString, unsupportedKeys)
            details.add(contentsOf: externallyStored)
        }

        account.supplyUserDetails(details)
    }

    private func _buildUser(from storage: UserStorage, isNew: Bool) -> AccountDetails {
        var details = AccountDetails()
        details.accountId = storage.accountId.uuidString
        details.name = storage.name
        details.genderIdentity = storage.genderIdentity
        details.dateOfBirth = storage.dateOfBirth
        details.isNewUser = isNew

        if let userId = storage.userId {
            details.userId = userId
        }

        if storage.password == nil {
            details.isAnonymous = true
        }
        return details
    }
}


extension InMemoryAccountService {
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

    @Observable
    @MainActor
    final class State {
        var presentingSecurityAlert = false
        var securityContinuation: CheckedContinuation<Void, any Error>?
    }

    fileprivate struct UserStorage {
        let accountId: UUID
        var userId: String?
        var password: String?
        var name: PersonNameComponents?
        var genderIdentity: GenderIdentity?
        var dateOfBirth: Date?
        var phoneNumbers: [String]? // swiftlint:disable:this discouraged_optional_collection

        init(
            accountId: UUID = UUID(), // swiftlint:disable:this function_default_parameter_at_end
            userId: String?,
            password: String?,
            name: PersonNameComponents? = nil,
            genderIdentity: GenderIdentity? = nil,
            dateOfBirth: Date? = nil,
            phoneNumbers: [String]? = nil // swiftlint:disable:this discouraged_optional_collection
        ) {
            self.accountId = accountId
            self.userId = userId
            self.password = password
            self.name = name
            self.genderIdentity = genderIdentity
            self.dateOfBirth = dateOfBirth
            self.phoneNumbers = phoneNumbers
        }
    }
}


extension InMemoryAccountService.UserStorage {
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


extension String {
    var assumeUUID: UUID {
        guard let id = UUID(uuidString: self) else {
            preconditionFailure("Invalid uuid format \(self)")
        }
        return id
    }
}

// swiftlint:disable:this file_length
