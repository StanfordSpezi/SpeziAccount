//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


protocol AnyIdentityProvider {
    var component: any AnyAccountSetupComponent { get }
}

protocol AnyAccountSetupComponent: Sendable {
    var id: UUID { get }
    var configuration: IdentityProviderConfiguration { get }
    @MainActor var anyView: AnyView { get }
}

struct AccountSetupComponent<V: View> {
    let id = UUID()
    let viewClosure: @Sendable @MainActor () -> V
    let configuration: IdentityProviderConfiguration


    init(viewClosure: @escaping @Sendable @MainActor () -> V, configuration: IdentityProviderConfiguration) {
        self.viewClosure = viewClosure
        self.configuration = configuration
    }
}


/// Declare an identity provider view component within your `AccountService`.
///
/// This property wrapper can be used within an ``AccountService`` implementation, to declare view components that are used in the
/// ``AccountSetup`` view as entry points to setting up an account with your `AccountService`.
/// For example, you might provide a SwiftUI Button view that is used to start the signup flow with a Single-Sign-On Provider your `AccountService` supports.
///
/// - Note: In the case that your view's initializer is isolated to `@MainActor` and your `AccountService` doesn't have this isolation guarantee, wrap the view into a new, empty view
///   that, therefore, provides an non-isolated initializer.
@propertyWrapper
public struct IdentityProvider<V: View> { // TODO: code example. + configuration example?
    private let viewClosure: @Sendable @MainActor () -> V
    private let configuration: IdentityProviderConfiguration


    /// The identity provider view.
    ///
    /// This view might be displayed in views like ``AccountSetup`` to provide an entry point to the given ``AccountService``.
    @MainActor public var wrappedValue: V {
        viewClosure()
    }


    /// Access the configuration of the identity provider.
    public var projectedValue: IdentityProviderConfiguration {
        configuration
    }


    /// Create a new identity provider declaration.
    /// - Parameters:
    ///   - wrappedValue: The View provided as an auto-closure.
    ///   - enabled: Flag indicating if this Identity Provider should be used at all.
    ///   - section: The section this identity provider is displayed in.
    public init(
        wrappedValue: @autoclosure @escaping @Sendable () -> V,
        enabled isEnabled: Bool = true,
        section: AccountSetupSection = .default
    ) {
        self.viewClosure = { @MainActor in
            wrappedValue()
        }
        self.configuration = IdentityProviderConfiguration(isEnabled: isEnabled, section: section)
    }
}


extension IdentityProvider: Sendable {}


extension AccountSetupComponent: AnyAccountSetupComponent {
    var anyView: AnyView {
        AnyView(viewClosure())
    }
}


extension IdentityProvider: AnyIdentityProvider {
    var component: any AnyAccountSetupComponent {
        AccountSetupComponent(viewClosure: viewClosure, configuration: configuration)
    }
}
