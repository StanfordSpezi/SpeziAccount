//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


public protocol AccountSetupViewStyle {
    associatedtype Service: AccountService

    associatedtype ButtonLabel: View
    associatedtype PrimaryView: View
    associatedtype AccountSummaryView: View

    // TODO that's not really a great way to deal with that?
    var service: Service { get set }

    @ViewBuilder
    func makeAccountServiceButtonLabel() -> ButtonLabel

    @ViewBuilder
    func makePrimaryView() -> PrimaryView

    @ViewBuilder
    func makeAccountSummary() -> AccountSummaryView
}
