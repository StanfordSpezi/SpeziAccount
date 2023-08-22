//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// A identity provider that provides account functionality through a one-click third-party account service.
///
/// - Important: Identity providers are currently not fully supported by `SpeziAccount`. They are not automatically
///     checked against the user-defined ``AccountValueConfiguration`` nor can impose any requirements.
///     They are not automatically integrated with ``AccountStorageStandard``.
public protocol IdentityProvider: Sendable {
    /// The view rendering the sign in button.
    associatedtype Button: View

    /// Render the sign in button.
    @ViewBuilder
    func makeSignInButton() -> Button
}
