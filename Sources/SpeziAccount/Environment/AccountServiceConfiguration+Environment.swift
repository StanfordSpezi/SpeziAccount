//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension EnvironmentValues {
    /// Access the ``AccountServiceConfiguration`` within the context of a ``DataDisplayView`` or ``DataEntryView``.
    ///
    /// - Note: Accessing this environment value outside the view body of such view types, you will receive a unusable
    ///     mock value.
    @Entry public var accountServiceConfiguration: AccountServiceConfiguration = .init(supportedKeys: .arbitrary)
}
