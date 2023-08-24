//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The gender identity of a user.
///
/// ## Topics
///
/// ### Model
/// - ``GenderIdentity``
public struct GenderIdentityKey: AccountKey {
    public typealias Value = GenderIdentity
    public typealias DataEntry = GenderIdentityPicker

    public static let name = LocalizedStringResource("GENDER_IDENTITY_TITLE", bundle: .atURL(from: .module))

    public static let category: AccountKeyCategory = .personalDetails

    public static let initialValue: InitialValue<Value> = .default(.preferNotToState)
}


extension AccountKeys {
    /// The gender identity ``AccountKey`` metatype.
    public var genderIdentity: GenderIdentityKey.Type {
        GenderIdentityKey.self
    }
}


extension AccountValues {
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
