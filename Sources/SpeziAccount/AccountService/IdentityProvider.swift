//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// An identity provider that provides account functionality through a one-click third-party account service.
public protocol IdentityProvider: AccountService where ViewStyle: IdentityProviderViewStyle {}
