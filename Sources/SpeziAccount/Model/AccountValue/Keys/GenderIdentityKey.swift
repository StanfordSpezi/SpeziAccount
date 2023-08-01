//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct GenderIdentityKey: AccountValueKey {
    public typealias Value = GenderIdentity
    public typealias DataEntry = GenderIdentityPicker

    public static let signupCategory: SignupCategory = .personalDetails
}


extension AccountValueKeys {
    public var genderIdentity: GenderIdentityKey.Type {
        GenderIdentityKey.self
    }
}


extension AccountValueStorageContainer {
    public var genderIdentity: GenderIdentityKey.Value? {
        storage[GenderIdentityKey.self]
    }
}


extension ModifiableAccountValueStorageContainer {
    public var genderIdentity: GenderIdentityKey.Value? {
        get {
            storage[GenderIdentityKey.self]
        }
        set {
            storage[GenderIdentityKey.self] = newValue
        }
    }
}


// MARK: - UI
extension GenderIdentityPicker: DataEntryView {
    public typealias Key = GenderIdentityKey

    public init(_ value: Binding<GenderIdentity>) {
        self.init(genderIdentity: value)
    }
}
