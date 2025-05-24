//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Options associated with an Account Key.
public struct AccountKeyOptions: OptionSet {
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
}


extension AccountKeyOptions: Hashable, Sendable, Codable {}


extension AccountKeyOptions {
    /// The account key supports to be displayed to the user.
    ///
    /// An Account Key always implicitly supports read access. Therefore, when `display` is supported, a ``DataDisplayView`` is required to be specified (or relying on a default implementation fo
    /// the given type).
    /// If ``mutable`` option is set as well, a ``DataEntryView`` is likewise required to be specified.
    public static let display = AccountKeyOptions(rawValue: 1 << 0)
    /// The account key supports mutation.
    ///
    /// This option marks the account key to support user-initiated (or think of as client-side initiated) mutation.
    /// Having this option not set does not prevent server-side permutation (e.g., as a side effect of some request).
    /// Instead it makes it explicit that the user (or rather client-side code) is allowed to mutate the value themselves (assuming some authorization checks).
    ///
    /// If the the ``display`` option is set, you must supply a ``DataEntryView`` to allow permutation from UI.
    public static let mutable = AccountKeyOptions(rawValue: 1 << 1)

    /// The default configuration for an Account Key.
    ///
    /// By default, an Account Key is ``display``ed and ``mutable``.
    public static let `default`: AccountKeyOptions = [.display, .mutable]
}
