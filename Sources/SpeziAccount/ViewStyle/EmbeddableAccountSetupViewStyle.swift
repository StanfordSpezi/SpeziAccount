//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


public protocol EmbeddableAccountSetupViewStyle: AccountSetupViewStyle where Service: EmbeddableAccountService {
    associatedtype EmbeddedView: View

    @ViewBuilder
    func makeEmbeddedAccountView() -> EmbeddedView
}
