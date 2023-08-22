//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A view style defining UI components for an associated ``IdentityProvider``.
public protocol IdentityProviderViewStyle: AccountSetupViewStyle where Service: IdentityProvider, PrimaryView == Never, ButtonLabel == Never {
    /// The view rendering the sign in button.
    associatedtype Button: View

    /// Render the sign in button.
    @ViewBuilder
    func makeSignInButton() -> Button
}


extension IdentityProviderViewStyle {
    /// Implementation that results in a fatal error as these methods are unavailable on identity providers.
    public func makeServiceButtonLabel() -> Never {
        preconditionFailure("makeServiceButtonLabel() is not available on `IdentityProvider`s")
    }

    /// Implementation that results in a fatal error as these methods are unavailable on identity providers.
    public func makePrimaryView() -> Never {
        preconditionFailure("makePrimaryView() is not available on `IdentityProvider`s")
    }
}
