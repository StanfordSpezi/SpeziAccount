//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension AccountDetails {
    /// The gender identity of a user.
    @AccountKey(
        name: LocalizedStringResource("GENDER_IDENTITY_TITLE", bundle: .atURL(from: .module)),
        category: .personalDetails,
        initial: .default(GenderIdentity.preferNotToState)
        // TODO: as: GenderIdentity.self
    )
    public var genderIdentity: GenderIdentity?
}


@KeyEntry(\.genderIdentity)
public extension AccountKeys { // swiftlint:disable:this no_extension_access_modifier
}



// TODO: move!
@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value>(
    name: LocalizedStringResource,
    category: AccountKeyCategory,
    initial: InitialValue<Value>,
    as: Value.Type = Value.self // TODO: default doesn't work?
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")

@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: StringProtocol>(
    name: LocalizedStringResource,
    category: AccountKeyCategory,
    initial: InitialValue<Value> = .empty("") // TODO: does that work to have a default value? or will it just be no syntax?
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")

// TODO: default for AdditiveArithmetic


@attached(member, names: arbitrary)
public macro KeyEntry<Value>(_ key: KeyPath<AccountDetails, Value>) = #externalMacro(module: "SpeziAccountMacros", type: "KeyEntryMacro")


@freestanding(expression)
public macro AccountKey2<Key: AccountKey>(
    _ key: KeyPath<AccountKeys, Key.Type>
) -> Key.Type = #externalMacro(module: "SpeziAccountMacros", type: "FreeStandingAccountKeyMacro")
