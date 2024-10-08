//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A component that manages user details.
///
/// An `AccountService` is a set of components that is capable of setting up and managing the ``AccountDetails`` for the global ``Account`` context.
///
/// This protocol imposes the minimal requirements for an `AccountService` where most of the account-related procedures
/// are entirely application defined.
/// This protocol only imposed requirements for account logout, deletion and modification functionalities.
///
/// - Important: Every user account is expected to have a primary and unique user identifier.
///     SpeziAccount requires a stable and internal ``AccountDetails/accountId`` unique user identifier and offers
///     a user visible ``AccountDetails/userId`` which can be customized using the ``UserIdConfiguration``.
///
/// You can learn more about creating an account service at: <doc:Creating-your-own-Account-Service>.
///
/// - Note: The in-memory account service ``InMemoryAccountService`` that is useful for previews and testing is also a great example
///     on how to implement a account service.
public protocol AccountService: Module, CustomStringConvertible, Sendable, EnvironmentAccessible {
    /// The configuration of the account service.
    var configuration: AccountServiceConfiguration { get }

    /// This method implements account logout functionality.
    ///
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the logout was unsuccessful,
    ///     inorder to present a localized description to the user.
    ///     Make sure to remain in a state where the user can easily retry the logout operation.
    func logout() async throws

    /// This method implements account deletion.
    ///
    /// This method should delete the account and all associated data of the currently signed in user.
    ///
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the removal was unsuccessful,
    ///     inorder to present a localized description to the user.
    ///     Make sure to remain in a state where the user can easily retry the removal operation.
    func delete() async throws

    /// This method implements modifications to the ``AccountDetails``.
    /// - Parameter modifications: The account modifications listing added, updated and removed account values.
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the modify operation was unsuccessful,
    ///     inorder to present a localized description to the user.
    ///     Make sure to remain in a state where the user can easily retry the removal operation.
    func updateAccountDetails(_ modifications: AccountModifications) async throws
}


extension AccountService {
    /// Default `CustomStringConvertible` returning the type name.
    public var description: String {
        "\(Self.self)"
    }
}
