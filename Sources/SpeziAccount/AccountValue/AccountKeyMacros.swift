//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO: add docs for the macros!

import SwiftUI

extension EmptyView: DataDisplayView, DataEntryView { // TODO: make an custom type for that?
    public typealias Value = Never

    public init(_ value: Never) {
        self.init()
    }

    public init(_ value: Binding<Never>) {
        self.init()
    }
}

@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as: Value.Type,
    initial: InitialValue<Value>,
    displayView: DataDisplay.Type = EmptyView.self,
    entryView: DataEntry.Type = EmptyView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")

@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: StringProtocol, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as: Value.Type,
    displayView: DataDisplay.Type = EmptyView.self,
    entryView: DataEntry.Type = EmptyView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: AdditiveArithmetic, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as: Value.Type,
    displayView: DataDisplay.Type = EmptyView.self,
    entryView: DataEntry.Type = EmptyView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: ExpressibleByArrayLiteral, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as: Value.Type,
    displayView: DataDisplay.Type = EmptyView.self,
    entryView: DataEntry.Type = EmptyView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(accessor, names: named(get), named(set))
@attached(peer, names: prefixed(__Key_))
public macro AccountKey<Value: ExpressibleByDictionaryLiteral, DataDisplay: DataDisplayView, DataEntry: DataEntryView>(
    name: LocalizedStringResource,
    category: AccountKeyCategory = .other,
    as: Value.Type,
    displayView: DataDisplay.Type = EmptyView.self,
    entryView: DataEntry.Type = EmptyView.self
) = #externalMacro(module: "SpeziAccountMacros", type: "AccountKeyMacro")


@attached(member, names: arbitrary)
public macro KeyEntry<Value>(
    _ key: KeyPath<AccountDetails, Value>
) = #externalMacro(module: "SpeziAccountMacros", type: "KeyEntryMacro")
