//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO: add docs for the macros!


@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value>(
    name: LocalizedStringResource,
    category: AccountKeyCategory,
    as: Value.Type,
    initial: InitialValue<Value>
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")

@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: StringProtocol>(
    name: LocalizedStringResource,
    category: AccountKeyCategory,
    as: Value.Type
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: AdditiveArithmetic>(
    name: LocalizedStringResource,
    category: AccountKeyCategory,
    as: Value.Type
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: ExpressibleByArrayLiteral>(
    name: LocalizedStringResource,
    category: AccountKeyCategory,
    as: Value.Type
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: ExpressibleByDictionaryLiteral>(
    name: LocalizedStringResource,
    category: AccountKeyCategory,
    as: Value.Type
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(member, names: arbitrary)
public macro KeyEntry<Value>(
    _ key: KeyPath<AccountDetails, Value>
) = #externalMacro(module: "SpeziAccountMacros", type: "KeyEntryMacro")
