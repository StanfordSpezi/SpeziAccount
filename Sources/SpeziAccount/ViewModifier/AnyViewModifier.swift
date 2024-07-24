//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension ViewModifier {
    func inject<V: View>(into view: V) -> AnyView {
        AnyView(view.modifier(self))
    }
}


extension View {
    /// Modify the view with an type-erased `ViewModifier`.
    /// - Parameter modifier: The view modifier.
    /// - Returns: The modified view.
    func anyModifier(_ modifier: any ViewModifier) -> some View {
        modifier.inject(into: self)
    }

    func anyModifiers(_ modifiers: [any ViewModifier]) -> some View {
        var anyView = AnyView(self) // TODO: avoid first anyView?
        for modifier in modifiers {
            anyView = modifier.inject(into: anyView)
        }
        return anyView
    }
}
