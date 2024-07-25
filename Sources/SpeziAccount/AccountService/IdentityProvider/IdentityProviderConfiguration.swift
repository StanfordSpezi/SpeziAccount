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


/// Defines the section a `IdentityProvider` is grouped into when displayed with `AccountSetup`.
///
/// The ``AccountSetup`` view uses the account section reported via the ``IdentityProvider`` property wrapper to group views.
/// SpeziAccount provides some pre-defined groups to semantically group different Identity Provider, however you can easily create additional sections if required.
/// The order of the section is defined by the ``rawValue`` in ascending order.
public struct AccountSetupSection {
    /// Defines the highest priority section.
    ///
    /// You would usually use this section to display a single identity provider that is generally preferred by your Account Service and might take up more space on
    /// the screen.
    public static let primary = AccountSetupSection(rawValue: 0)
    /// The default section.
    public static let `default` = AccountSetupSection(rawValue: 100)
    /// Section dedicated for Single-Sign-On providers.
    ///
    /// You may use this section to display Button of Single-Sign-On Providers like Sign in with Apple at the bottom of the ``AccountSetup`` view.
    public static let singleSignOn = AccountSetupSection(rawValue: 200)


    /// The raw value of the section.
    ///
    /// This number is used to order the section in ascending order. Lowest number is displayed on the top.
    public let rawValue: UInt8

    /// Initialize a new section with its raw value.
    /// - Parameter rawValue: The raw value that is used to order section in ascending order.
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}


/// The configuration of a `IdentityProvider`.
///
/// Encapsulates all edit-able configuration of a ``IdentityProvider`` declaration.
/// You may use the ``IdentityProvider/projectedValue`` (using the `$` notation) of your Identity Provider declaration to access and change this configuration.
@Observable
public final class IdentityProviderConfiguration {
    private let _isEnabled: ManagedAtomic<Bool>
    private let _placement: ManagedAtomic<AccountSetupSection>

    /// Determine if the identity provider should be enabled.
    ///
    /// If disabled the identity provider is not shown to the user in the ``AccountSetup`` view.
    /// - Note: You must provide at least one enabled identity provider for the ``AccountSetup`` view to be useful.
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

    /// The section this identity provider is displayed in.
    public var section: AccountSetupSection {
        get {
            access(keyPath: \.section)
            return _placement.load(ordering: .relaxed)
        }
        set {
            withMutation(keyPath: \.section) {
                _placement.store(newValue, ordering: .relaxed)
            }
        }
    }

    init(isEnabled: Bool, section: AccountSetupSection) {
        self._isEnabled = ManagedAtomic(isEnabled)
        self._placement = ManagedAtomic(section)
    }
}


extension AccountSetupSection: Sendable, Hashable, RawRepresentable, AtomicValue {}


extension AccountSetupSection: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}


extension IdentityProviderConfiguration: Sendable {}
