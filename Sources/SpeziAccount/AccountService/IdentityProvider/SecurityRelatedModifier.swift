//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


protocol AnySecurityRelatedModifier {
    var securityModifier: AnySecurityModifier { get }
}


protocol AnySecurityModifier: Sendable {
    @MainActor var anyViewModifier: any ViewModifier { get }
}


struct SecurityModifier<V: ViewModifier> {
    let modifierClosure: @Sendable @MainActor () -> V

    init(_ modifierClosure: @escaping @Sendable @MainActor () -> V) {
        self.modifierClosure = modifierClosure
    }
}


// TODO: review file placement and naming!
@propertyWrapper
public struct SecurityRelatedModifier<V: ViewModifier> {
    private let modifierClosure: @Sendable @MainActor () -> V

    /// The security related modifier instance.
    @MainActor public var wrappedValue: V {
        modifierClosure()
    }

    public init(wrappedValue: @autoclosure @escaping @Sendable () -> V) {
        self.modifierClosure = { @MainActor in
            wrappedValue()
        }
    }
}


extension SecurityModifier: AnySecurityModifier {
    var anyViewModifier: any ViewModifier {
        modifierClosure()
    }
}


extension SecurityRelatedModifier: AnySecurityRelatedModifier {
    var securityModifier: any AnySecurityModifier {
        SecurityModifier(modifierClosure)
    }
}
