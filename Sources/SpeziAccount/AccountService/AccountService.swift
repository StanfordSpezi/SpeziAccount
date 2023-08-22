//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// A `AccountService` is a set of components that is capable of setting up and managing the ``AccountDetails`` for the global ``Account`` context.
///
/// This protocol imposes the minimal requirements for an `AccountService` where most of the account-related procedures
/// are entirely application defined. This protocol requires functionality for account signup, modifications,
/// logout and removal.
///
/// You may improve the user experience or rely on user interface defaults if you adopt protocols like
/// ``EmbeddableAccountService`` or ``UserIdPasswordAccountService``.
///
/// - Note: `SpeziAccount` provides the generalized ``UserIdKey`` unique user identifier that can be customized
///     using the ``UserIdConfiguration``.
///
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

    /// The configuration of the account service.
    var configuration: AccountServiceConfiguration { get }

    /// A ``AccountSetupViewStyle`` that is capable of rendering UI elements associated with the account service.
    ///
    /// - Note: Define this as a computed property to resolve the cyclic type dependence.
    var viewStyle: ViewStyle { get }


    /// Create a new user account for the provided ``SignupDetails``.
    ///
    /// - Note: You must call ``Account/supplyUserDetails(_:)`` eventually once the user context was established after this call.
    /// - Parameter signupDetails: The signup details
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the signup operation was unsuccessful,
    ///     inorder to present a localized description to the user.
    ///     Make sure to remain in a state where the user can easily retry the signup operation.
    func signUp(signupDetails: SignupDetails) async throws

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
