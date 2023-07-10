//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// An Account Service is a set of components that is capable setting up and managing an ``Account`` context.
///
/// This base protocol imposes the minimal requirements for an AccountService where setup procedures are entirely
/// application defined only requiring logout functionality.
/// You may improve the user experience or rely on user interface defaults if you adopt protocols like
/// ``EmbeddableAccountService`` or ``KeyPasswordBasedAccountService``. TODO docs?
///
/// You can learn more about creating an account service at: <doc:CreateAnAccountService>.
public protocol AccountService: AnyObject, Hashable, CustomStringConvertible { // TODO identifiable? do we wanna mandate Actor?
    /// The ``AccountSetupViewStyle`` will be used to customized the look and feel of the ``AccountSetup`` view.
    associatedtype ViewStyle: AccountSetupViewStyle
    typealias ID = ObjectIdentifier

    /// An identifier to uniquely identify an `AccountService`.
    var id: ID { get }

    // TODO provide access to `Account` to communicate changes back to the App

    var viewStyle: ViewStyle { get } // TODO document computed property!

    /// This method implements ``Account`` logout functionality.
    ///
    /// TODO comments on logging out an not logged in user!
    ///
    /// - Throws: Throw an `Error` type conforming to `LocalizedError` if the logout was unsuccessful
    ///   to present a localized description to the user on a failed logout.
    ///   Make sure to remain in a state where the user is capable of retrying the logout process.
    func logout() async throws

    // TODO we will/should enforce a Account removal functionality

    // TODO document requirement to store it as a weak reference!
    // func inject(account: AccountBox)
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

    /// Default `Hashable` implementation by relying on the hashable ``id`` property.
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }

    /// Default `Equatable` implementation by relying on the hashable ``id`` property.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
