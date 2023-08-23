//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// An ``AccountService`` that relies on ``UserIdKey`` and ``PasswordKey`` as primary authentication credentials.
///
/// This type of ``AccountService`` provides a default set of UI components through ``UserIdPasswordAccountSetupViewStyle``
/// for all functionalities.
///
/// - Note: The type of userId might be configured using ``UserIdConfiguration``. Additionally make sure, if you
///     require the ``UserIdKey`` and ``PasswordKey`` to be present, you have to manually specify the ``RequiredAccountKeys``
///     configuration.
///
/// ## Topics
///
/// ### Default View Style
///
/// - ``DefaultUserIdPasswordAccountSetupViewStyle``
///
/// ### Mock Implementations for SwiftUI Previews
///
/// - ``MockUserIdPasswordAccountService``
public protocol UserIdPasswordAccountService: AccountService, EmbeddableAccountService where ViewStyle: UserIdPasswordAccountSetupViewStyle {
    /// This method implements login functionality using ``UserIdKey`` and ``PasswordKey``-based credentials.
    /// - Parameters:
    ///   - userId: The userId of the account.
    ///   - password: The plain-text password for the account.
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the login operation was unsuccessful,
    ///     inorder to present a localized description to the user.
    ///     Make sure to remain in a state where the user can easily retry the login operation.
    func login(userId: String, password: String) async throws

    /// This method implements password reset functionality for a given userId.
    /// - Parameter userId: The userId to
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the password reset operation was unsuccessful,
    ///     inorder to present a localized description to the user.
    ///     Make sure to remain in a state where the user can easily retry the password reset operation.
    func resetPassword(userId: String) async throws
}


extension UserIdPasswordAccountService where ViewStyle == DefaultUserIdPasswordAccountSetupViewStyle<Self> {
    /// Default UI components for userId and password-based account services.
    public var viewStyle: DefaultUserIdPasswordAccountSetupViewStyle<Self> {
        DefaultUserIdPasswordAccountSetupViewStyle(using: self)
    }
}
