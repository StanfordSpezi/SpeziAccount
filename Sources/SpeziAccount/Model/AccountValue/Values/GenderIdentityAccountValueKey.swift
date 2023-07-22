//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct GenderIdentityAccountValueKey: AccountValueKey {
    public typealias Value = GenderIdentity
    public typealias DataEntry = GenderIdentityPicker

    public static let signupCategory: SignupCategory = .personalDetails
}


extension AccountValueKeys {
    public var genderIdentity: GenderIdentityAccountValueKey.Type {
        GenderIdentityAccountValueKey.self
    }
}


extension AccountValueStorageContainer {
    public var genderIdentity: GenderIdentityAccountValueKey.Value? {
        storage[GenderIdentityAccountValueKey.self]
    }
}


extension ModifiableAccountValueStorageContainer {
    public var genderIdentity: GenderIdentityAccountValueKey.Value? {
        get {
            storage[GenderIdentityAccountValueKey.self]
        }
        set {
            storage[GenderIdentityAccountValueKey.self] = newValue
        }
    }
}


// MARK: - UI
extension GenderIdentityPicker: DataEntryView {
    public typealias Key = GenderIdentityAccountValueKey

    public init(_ value: Binding<GenderIdentity>) {
        self.init(genderIdentity: value)
    }
}
