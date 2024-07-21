//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// A view style defining UI components for an associated ``EmbeddableAccountService``.
public protocol EmbeddableAccountSetupViewStyle: AccountSetupViewStyle {
    /// The view that is embedded into the ``AccountSetup`` view if the associated ``EmbeddableAccountService``
    /// is the only configured embeddable account service.
    associatedtype EmbeddedView: View

    /// The view that is embedded into the ``AccountSetup`` view if applicable.
    @ViewBuilder
    @MainActor
    func makeEmbeddedAccountView(_ service: any EmbeddableAccountService) -> EmbeddedView
}
