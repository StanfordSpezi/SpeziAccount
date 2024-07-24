//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// TODO: review file placement and naming!

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


@propertyWrapper
public struct IdentityProvider<V: View> { // TODO: document MainActor workaround
    private let viewClosure: @Sendable @MainActor () -> V
    private let configuration: IdentityProviderConfiguration


    @MainActor public var wrappedValue: V {
        viewClosure()
    }

    public var projectedValue: IdentityProviderConfiguration {
        configuration
    }

    public init(
        wrappedValue: @autoclosure @escaping @Sendable () -> V,
        enabled isEnabled: Bool = true,
        placement: IdentityProviderConfiguration.Placement = .default
    ) {
        self.viewClosure = { @MainActor in
            wrappedValue()
        }
        self.configuration = IdentityProviderConfiguration(isEnabled: isEnabled, placement: placement)
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
