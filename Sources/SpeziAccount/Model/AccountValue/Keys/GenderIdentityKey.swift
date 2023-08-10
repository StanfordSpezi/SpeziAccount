//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The gender identity of a user.
public struct GenderIdentityKey: AccountValueKey {
    public typealias Value = GenderIdentity
    public typealias DataEntry = GenderIdentityPicker

    public static let category: AccountValueCategory = .personalDetails
}


extension AccountValueKeys {
    /// The gender identity ``AccountValueKey``.
    public var genderIdentity: GenderIdentityKey.Type {
        GenderIdentityKey.self
    }
}


extension AccountValueStorageContainer {
    /// Access the gender identity of a user.
    public var genderIdentity: GenderIdentity? {
        storage[GenderIdentityKey.self]
    }
}


// MARK: - UI
extension GenderIdentityPicker: DataEntryView {
    public typealias Key = GenderIdentityKey

    public init(_ value: Binding<GenderIdentity>) {
        self.init(genderIdentity: value)
    }
}
