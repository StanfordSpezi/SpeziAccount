//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Atomics
import Spezi
import SwiftUI

public struct Placement { // TODO: rename
    public static let embedded = Placement(rawValue: 0) // TODO: docs: only one embedded view allowed!
    public static let `default` = Placement(rawValue: 100) // TODO: rename?
    public static let external = Placement(rawValue: 200)

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

@Observable
public final class IdentityProviderConfiguration {
    private let _isEnabled: ManagedAtomic<Bool>
    private let _placement: ManagedAtomic<Placement>

    public var isEnabled: Bool {
        get {
            access(keyPath: \.isEnabled)
            return _isEnabled.load(ordering: .relaxed)
        }
        set {
            withMutation(keyPath: \.isEnabled) {
                _isEnabled.store(newValue, ordering: .relaxed)
            }
        }
    }

    public var placement: Placement {
        get {
            access(keyPath: \.placement)
            return _placement.load(ordering: .relaxed)
        }
        set {
            withMutation(keyPath: \.placement) {
                _placement.store(newValue, ordering: .relaxed)
            }
        }
    }

    public init(isEnabled: Bool, placement: Placement) {
        self._isEnabled = ManagedAtomic(isEnabled)
        self._placement = ManagedAtomic(placement)
    }
}


extension Placement: Sendable, Hashable, RawRepresentable, AtomicValue {}


extension Placement: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}


extension IdentityProviderConfiguration: Sendable {}
