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
    /// The associated ``AccountService``.
    associatedtype Service: AccountService

    /// The button label rendered in the list of account services in ``AccountSetup``
    associatedtype ButtonLabel: View
    /// The primary view that is opened as the destination of the ``ButtonLabel``.
    associatedtype PrimaryView: View
    /// A small account summary that is rendered if ``AccountSetup`` is presented on an already
    /// signed in user.
    associatedtype AccountSummaryView: View

    /// The associated ``AccountService`` instance.
    var service: Service { get }

    /// The button label in the list of account services for the ``AccountSetup`` view.
    @ViewBuilder
    func makeServiceButtonLabel() -> ButtonLabel

    /// The primary view that is opened as the destination of the ``makeServiceButtonLabel()-6ihdh`` button.
    @ViewBuilder
    func makePrimaryView() -> PrimaryView

    /// The account summary that is presented in the ``AccountSetup`` for an already signed in user.
    @ViewBuilder
    func makeAccountSummary(details: AccountDetails) -> AccountSummaryView
}


extension AccountSetupViewStyle {
    public func makeServiceButtonLabel() -> some View {
        Group {
            service.configuration.image
                .font(.title2)
            Text(service.configuration.name)
        }
            .accountServiceButtonBackground()
    }

    public func makeAccountSummary(details: AccountDetails) -> some View {
        AccountSummaryBox(details: details)
    }
}
