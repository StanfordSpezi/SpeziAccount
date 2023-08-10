//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// A `AccountService` is a set of components that is capable of setting up and managing the ``AccountDetails`` for the ``Account`` context.
///
/// TODO how to best describe the `Account` thingy?
///
/// This protocol imposes the minimal requirements for an `AccountService` where most of the account-related procedures
/// are entirely application defined, only requiring logout functionality.
/// You may improve the user experience or rely on user interface defaults if you adopt protocols like
/// ``EmbeddableAccountService`` or ``UserIdPasswordAccountService``. TODO do this with topics!
/// TODO document use of the AccountReference property wrapper => topics!
/// You can learn more about creating an account service at: <doc:CreateAnAccountService>.
public protocol AccountService: AnyObject, Identifiable, Hashable, CustomStringConvertible, Sendable where ID == ObjectIdentifier {
    /// The ``AccountSetupViewStyle`` will be used to customized the look and feel of the ``AccountSetup`` view.
    associatedtype ViewStyle: AccountSetupViewStyle

    /// An identifier to uniquely identify an `AccountService`.
    var id: ID { get }

    var configuration: AccountServiceConfiguration { get }

    var viewStyle: ViewStyle { get } // TODO document computed property!


    func signUp(signupDetails: SignupDetails) async throws

    /// This method implements account logout functionality.
    ///
    /// TODO comments on logging out an not logged in user!
    ///
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the logout was unsuccessful
    ///   to present a localized description to the user on a failed logout.
    ///   Make sure to remain in a state where the user is capable of retrying the logout process.
    func logout() async throws

    /// This method implements account removal.
    ///
    /// This method should remove the account of the currently signed in user.
    ///
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the removal was unsuccessful
    ///   to present a localized description to the user on a failed account removal.
    ///   Make sure to remain in a state where the user is capable of retrying the removal process.
    func remove() async throws


    // TODO its the account services choice to mandate how to handle userId and password changes!
    func updateAccountDetails(_ details: ModifiedAccountDetails) async throws

    func updateAccountDetail<Key: RequiredAccountValueKey>(_ key: Key.Type, value: Key.Value) async throws

    func updateAccountDetail<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value) async throws

    func updateAccountDetail<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value?) async throws

    func updateAccountDetail<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value?) async throws
}


extension AccountService {
    /// Default implementation that instantiates an `ObjectIdentifier` using `Self.self`.
    public var id: ID {
        ObjectIdentifier(Self.self)
    }

    /// Default `CustomStringConvertible` returning the type name.
    public var description: String {
        "\(Self.self)"
    }

    /// Default `Equatable` implementation by relying on the hashable ``AccountService/id-9icbd`` property.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    /// Default `Hashable` implementation by relying on the hashable ``AccountService/id-9icbd`` property.
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}


extension AccountService {
    public func updateAccountDetail0<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value) async throws {
        let modifiedDetails = ModifiedAccountDetails.Builder()
            .set(Key.self, value: value)
            .build()
        try await updateAccountDetails(modifiedDetails)
    }

    public func updateAccountDetail<Key: RequiredAccountValueKey>(_ key: Key.Type, value: Key.Value) async throws {
        try await updateAccountDetail0(Key.self, value: value)
    }

    public func updateAccountDetail<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value) async throws {
        try await updateAccountDetail0(Key.self, value: value)
    }

    public func updateAccountDetail<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value?) async throws {
        guard let value else {
            return
        }

        try await updateAccountDetail0(Key.self, value: value)
    }

    public func updateAccountDetail<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value?) async throws {
        try await updateAccountDetail(Key.self, value: value)
    }
}
