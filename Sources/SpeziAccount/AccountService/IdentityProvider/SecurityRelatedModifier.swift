//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


protocol AnySecurityRelatedModifier {
    var securityModifier: AnySecurityModifier { get }
}


protocol AnySecurityModifier: Sendable {
    @MainActor var anyViewModifier: any ViewModifier { get }
}


struct SecurityModifier<V: ViewModifier> {
    let modifierClosure: @Sendable @MainActor () -> V

    init(_ modifierClosure: @escaping @Sendable @MainActor () -> V) {
        self.modifierClosure = modifierClosure
    }
}


/// Inject a `ViewModifier` into views that contain security related operations.
///
/// You can use the `SecurityRelatedModifier` to provide a `ViewModifier` that is injected into all Account views that contain security related operations.
/// For example, when performing a password change userId change or account deletion the modifier will be injected such that you can display additional UI before performing certain
/// account operations.
///
/// Within the following `AccountService` methods you can be sure that the modifier is injected:
/// - ``AccountService/updateAccountDetails(_:)``
/// - ``AccountService/delete()``
///
/// Below is a short code example how you would supply such a modifier.
/// ```swift
/// final class MyAccountService: AccountService {
///     @SecurityRelatedModifier var myModifier = MyModifier()
///
///     func delete() async throws {
///         // pop up an alert that requires entering the password
///         try await myModifier.ensureAuthenticated()
///
///         // perform delete
///     }
/// }
/// ```
///
/// You can use the [`Environment`](https://developer.apple.com/documentation/swiftui/environment/init(_:)-evj6) property wrapper to access your account service
/// in your view modifier.
///
/// ```swift
/// struct MyModifier: ViewModifier {
///     @Environment(MyAccountService.self) var accountService
///
///     func func body(content: Content) -> some View {
///         // your modifier that, e.g., adds an alert that pops up an authorization request
///     }
/// }
/// ```
@propertyWrapper
public struct SecurityRelatedModifier<V: ViewModifier> {
    private let modifierClosure: @Sendable @MainActor () -> V

    /// The security related modifier instance.
    @MainActor public var wrappedValue: V {
        modifierClosure()
    }

    /// Create a new security related modifier declaration.
    /// - Parameter wrappedValue: An auto-closure creating a new security related modifier each time it is used.
    public init(wrappedValue: @autoclosure @escaping @Sendable () -> V) {
        self.modifierClosure = { @MainActor in
            wrappedValue()
        }
    }
}


extension SecurityModifier: AnySecurityModifier {
    var anyViewModifier: any ViewModifier {
        modifierClosure()
    }
}


extension SecurityRelatedModifier: AnySecurityRelatedModifier {
    var securityModifier: any AnySecurityModifier {
        SecurityModifier(modifierClosure)
    }
}
