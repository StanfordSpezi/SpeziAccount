//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// A view style defining UI components for an associated ``UserIdPasswordAccountService``.
public protocol UserIdPasswordAccountSetupViewStyle: EmbeddableAccountSetupViewStyle {
    /// A view that is rendered to signup a new user.
    associatedtype SignupView: View
    /// A view that is rendered to reset the user's password.
    associatedtype PasswordResetView: View

    /// The view that is presented to signup a new user.
    @ViewBuilder
    @MainActor
    func makeSignupView(_ service: any UserIdPasswordAccountService) -> SignupView

    /// The view that is presented to reset a user's password.
    @ViewBuilder
    @MainActor
    func makePasswordResetView(_ service: any UserIdPasswordAccountService) -> PasswordResetView
}


extension UserIdPasswordAccountSetupViewStyle {
    /// Default primary view using ``UserIdPasswordPrimaryView``.
    @MainActor
    public func makePrimaryView(_ service: any AccountService) -> some View {
        guard let service = service as? any UserIdPasswordAccountService else {
            preconditionFailure("Received account service of type \(type(of: service)) when expecting one of type \((any UserIdPasswordAccountService).self)")
        }
        return UserIdPasswordPrimaryView(using: service)
    }

    /// Default embedded account view using ``UserIdPasswordEmbeddedView``.
    @MainActor
    public func makeEmbeddedAccountView(_ service: any EmbeddableAccountService) -> some View {
        guard let service = service as? any UserIdPasswordAccountService else {
            preconditionFailure("Received account service of type \(type(of: service)) when expecting one of type \((any UserIdPasswordAccountService).self)")
        }
        // TODO: return UserIdPasswordEmbeddedView(using: service)
        return EmptyView()
    }

    /// Default signup view using ``SignupForm``.
    @MainActor
    public func makeSignupView(_ service: any UserIdPasswordAccountService) -> some View {
        // TODO: SignupForm(using: service)
        return EmptyView()
    }

    /// Default password reset view using ``UserIdPasswordResetView`` and ``SuccessfulPasswordResetView``.
    @MainActor
    public func makePasswordResetView(_ service: any UserIdPasswordAccountService) -> some View {
        /*
         TODO: UserIdPasswordResetView(using: service) {
         SuccessfulPasswordResetView()
         }
         */
        return EmptyView()
    }
}
