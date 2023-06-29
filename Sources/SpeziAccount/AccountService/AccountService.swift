//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// TODO make everything public!

// TODO app needs access to the "primary?"/signed in (we don't support multi account sign ins!) account service!
//  -> logout functionality
//  -> AccountSummary
//  -> allows for non-account-service-specific app implementations (e.g., easily switch for testing) => otherwise cast!

/// An Account Service is a set of components that is capable setting up and managing an ``Account`` context.
///
/// This base protocol imposes the minimal requirements for an AccountService where setup procedures are entirely
/// application defined only requiring logout functionality.
/// You may improve the user experience or rely on user interface defaults if you adopt protocols like
/// ``EmbeddableAccountService`` or ``KeyPasswordBasedAccountService``. TODO docs?
///
/// You can learn more about creating an account service at: <doc:CreateAnAccountService>.
public protocol AccountService { // TODO reevaluate DocC link!
    /// The ``AccountSetupViewStyle`` will be used to customized the look and feel of the ``AccountSetup`` view.
    associatedtype ViewStyle: AccountSetupViewStyle

    // TODO provide access to `Account` to communicate changes back to the App

    var viewStyle: ViewStyle { get } // TODO this has to be a computed property as of right now!

    /// This method implements ``Account`` logout functionality.
    ///
    /// TODO comments on logging out an not logged in user!
    ///
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the logout was unsuccessful
    ///   to present a localized description to the user on a failed logout.
    ///   Make sure to remain in a state where the user is capable of retrying the logout process.
    func logout() async throws

    // TODO we will/should enforce a Account removal functionality
}
