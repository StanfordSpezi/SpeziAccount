//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// A view style defining UI components for an associated ``AccountService``.
public protocol AccountSetupViewStyle {
    /// The button label rendered in the list of account services in ``AccountSetup``
    associatedtype ButtonLabel: View
    /// The primary view that is opened as the destination of the ``ButtonLabel``.
    associatedtype PrimaryView: View
    /// A small account summary that is rendered if ``AccountSetup`` is presented on an already
    /// signed in user.
    associatedtype AccountSummaryView: View

    /// A `ViewModifier` that is injected into views with security related operations.
    ///
    /// This modifier is injected into views that expose security related operations like changing the password
    /// or change the user identifier. It is guaranteed that this modifier is not injected twice into the same
    /// view hierarchy.
    ///
    /// - Note: It is advised to implement this as a computed property.
    var securityRelatedViewModifier: any ViewModifier { get }


    /// The button label in the list of account services for the ``AccountSetup`` view.
    @ViewBuilder
    @MainActor
    func makeServiceButtonLabel(_ service: any AccountService) -> ButtonLabel

    /// The primary view that is opened as the destination of the ``makeServiceButtonLabel(_:)-54dx4`` button.
    @ViewBuilder
    @MainActor
    func makePrimaryView(_ service: any AccountService) -> PrimaryView

    /// The account summary that is presented in the ``AccountSetup`` for an already signed in user.
    @ViewBuilder
    @MainActor
    func makeAccountSummary(_ service: any AccountService, details: AccountDetails) -> AccountSummaryView
}


extension AccountSetupViewStyle {
    /// Default implementation that doesn't modify anything.
    public var securityRelatedViewModifier: any ViewModifier {
        NoopModifier()
    }


    /// Default service button label using the ``AccountServiceName`` and ``AccountServiceImage`` configurations.
    @MainActor
    public func makeServiceButtonLabel(_ service: any AccountService) -> some View {
        HStack {
            service.configuration.image
                .font(.title2)
                .accessibilityHidden(true)
            Text(service.configuration.name)
        }
            .accountServiceButtonBackground()
    }

    /// Default account summary using ``AccountSummaryBox``.
    @MainActor
    public func makeAccountSummary(_ service: any AccountService, details: AccountDetails) -> some View {
        AccountSummaryBox(details: details)
    }
}
