//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct SignupProviderComplianceKey: PreferenceKey {
    struct Entry: Equatable {
        let date: Date
        let compliance: SignupProviderCompliance

        init(_ compliance: SignupProviderCompliance) {
            self.date = .now
            self.compliance = compliance
        }
    }

    static let defaultValue: Entry? = nil

    static func reduce(value: inout Entry?, nextValue: () -> Entry?) {
        // reduce to the value that is not nil and newest

        let next = nextValue()

        guard let previous = value else {
            value = next
            return
        }

        if let next, next.date >= previous.date {
            value = next
        }
    }
}


/// Define the compliance level of a custom signup provider.
///
/// SpeziAccount imposes requirements on account keys using ``AccountValueConfiguration`` which is supplied by the framework user.
/// This specifies which account keys are required and optional during signup.
/// Some signup provider, typically one external ones like a Single-Sign-On provider, might not be able to comply with that.
///
/// The `SignupProviderCompliance` is used by the ``AccountSetup`` view to reason about the compliance of the signup provider.
///
/// Use the ``SwiftUI/View/reportSignupProviderCompliance(_:)`` to set the compliance for your custom signup provider, if necessary.
///
/// - Note: The compliance preference is automatically set when using the ``SignupForm`` or the ``SignInWithAppleButton``.
public struct SignupProviderCompliance {
    enum VisualizedAccountKeys {
        case all
        case only(_ keys: [any AccountKey.Type])
    }

    fileprivate let creationDate: Date = .now

    let visualizedAccountKeys: VisualizedAccountKeys
}


extension SignupProviderCompliance {
    /// The signup provider is compliant.
    ///
    /// The signup provider is compliant and displays all account keys with ``AccountKeyRequirement/required`` and ``AccountKeyRequirement/collected`` requirements.
    public static var compliant: SignupProviderCompliance {
        SignupProviderCompliance(visualizedAccountKeys: .all)
    }

    /// The signup provider is not compliant and only asked for a specific set of account keys.
    ///
    /// - Parameter keys: The set of account keys the signup provider asked for. These keys are are not repeated in the ``FollowUpInfoSheet``.
    /// - Returns: The signup provider compliance description.
    public static func askedFor(keys: [any AccountKey.Type]) -> SignupProviderCompliance {
        SignupProviderCompliance(visualizedAccountKeys: .only(keys))
    }

    /// The signup provider is not compliant and only asked for a specific set of account keys.
    ///
    /// - Parameter keys: The set of account keys the signup provider asked for. These keys are are not repeated in the ``FollowUpInfoSheet``.
    /// - Returns: The signup provider compliance description.
    public static func askedFor(keys: AccountKeyCollection) -> SignupProviderCompliance {
        askedFor(keys: keys._keys)
    }

    /// The signup provider is not compliant and only asked for a specific set of account keys.
    ///
    /// - Parameter keys: The set of account keys the signup provider asked for. These keys are are not repeated in the ``FollowUpInfoSheet``.
    /// - Returns: The signup provider compliance description.
    public static func askedFor(@AccountKeyCollectionBuilder keys: () -> [any AccountKeyWithDescription]) -> SignupProviderCompliance {
        askedFor(keys: AccountKeyCollection(keys))
    }
}


extension SignupProviderCompliance.VisualizedAccountKeys: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case let (.only(lhsKeys), .only(rhsKeys)):
            return lhsKeys.map { ObjectIdentifier($0) } == rhsKeys.map { ObjectIdentifier($0) }
        default:
            return false
        }
    }
}


extension SignupProviderCompliance: Sendable, Equatable {}


extension View {
    /// Informs the parent account setup view about compliance of the signup provider.
    ///
    /// SpeziAccount imposes requirements on account keys using ``AccountValueConfiguration`` which is supplied by the framework user.
    /// This specifies which account keys are required and optional during signup.
    /// Some signup provider, typically one external ones like a Single-Sign-On provider, might not be able to comply with that.
    ///
    /// This modifier can be used to inform the ``AccountSetup`` view about the compliance of the signup provider.
    /// Make sure to set the compliance level from within the view before calling the signup procedure of the account service.
    ///
    /// - Note: The compliance preference is automatically set when using the ``SignupForm`` or the ``SignInWithAppleButton``.
    ///
    /// ```swift
    /// struct MyProvider: View {
    ///     @Environment(MyAccountService.self)
    ///     private var service
    ///
    ///     @State private var compliance: SignupProviderCompliance?
    ///
    ///     var body: some View {
    ///         Button("Signup") {
    ///             compliance = .askedFor {
    ///                 \.name
    ///             }
    ///             try? service.performSignup()
    ///         }
    ///             .reportSignupProviderCompliance(compliance)
    ///     }
    /// }
    /// ```
    public func reportSignupProviderCompliance(_ compliance: SignupProviderCompliance?) -> some View {
        preference(key: SignupProviderComplianceKey.self, value: compliance.map { .init($0) })
    }

    func receiveSignupProviderCompliance(receive action: @escaping (SignupProviderCompliance?) -> Void) -> some View {
        onPreferenceChange(SignupProviderComplianceKey.self) { compliance in
            action(compliance?.compliance)
        }
    }
}
