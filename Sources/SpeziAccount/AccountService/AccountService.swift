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
public protocol AccountService: AnyObject, Hashable, CustomStringConvertible, Sendable, Identifiable {
    /// The ``AccountSetupViewStyle`` will be used to customized the look and feel of the ``AccountSetup`` view.
    associatedtype ViewStyle: AccountSetupViewStyle

    /// An identifier to uniquely identify an `AccountService`.
    ///
    /// This identifier is used to uniquely identify an account service that persists across process instances.
    ///
    /// - Important: A default implementation is defined that relies on the type name. If you rename the account service
    ///     type without supplying a manual `id` implementation, components like a ``AccountStorageStandard`` won't
    ///     be able to associate existing user details with this account service.
    var id: String { get }

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

    /// This method implements account deletion.
    ///
    /// This method should delete the account and all associated data of the currently signed in user.
    ///
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the removal was unsuccessful
    ///   to present a localized description to the user on a failed account removal.
    ///   Make sure to remain in a state where the user is capable of retrying the removal process.
    func delete() async throws


    // TODO docs: its the account services choice to mandate how to handle userId and password changes!
    func updateAccountDetails(_ modifications: AccountModifications) async throws
}


extension AccountService {
    /// Default implementation that uses the type name as an unique identifier.
    public var id: String {
        description
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
