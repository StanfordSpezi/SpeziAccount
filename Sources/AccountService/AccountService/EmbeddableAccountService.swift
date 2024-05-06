//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A embeddable ``AccountService`` allows to render simplified UI in the ``AccountSetup`` view.
///
/// By default, the ``AccountSetup`` renders all ``AccountService`` as a list of buttons that navigate
/// to ``AccountSetupViewStyle/makePrimaryView(_:)`` where login and signup flows are completely defined by the ``AccountService``.
///
/// However, if there is a single `EmbeddableAccountService` in the list of all configured account service, this
/// account service is directly embedded into the main ``AccountSetup`` view for easier access.
/// The view is rendered using ``EmbeddableAccountSetupViewStyle/makeEmbeddedAccountView(_:)``
public protocol EmbeddableAccountService: AccountService where ViewStyle: EmbeddableAccountSetupViewStyle {}
