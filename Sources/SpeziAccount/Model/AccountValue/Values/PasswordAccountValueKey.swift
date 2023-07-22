//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct PasswordAccountValueKey: RequiredAccountValueKey {
    public typealias Value = String

    public static let signupCategory: SignupCategory = .credentials
}


extension AccountValueKeys {
    // TODO is password update special (requires existing knowledge?)
    public var password: PasswordAccountValueKey.Type {
        PasswordAccountValueKey.self
    }
}


extension SignupRequest {
    public var password: PasswordAccountValueKey.Value {
        storage[PasswordAccountValueKey.self]
    }
}


// MARK: - UI
extension PasswordAccountValueKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = PasswordAccountValueKey

        @Binding private var password: Value

        @StateObject var validation = ValidationEngine()

        public init(_ value: Binding<Value>) {
            self._password = value
        }

        public var body: some View {
            VerifiableTextField("UP_PASSWORD".localized(.module), text: $password, type: .secure)
                .environmentObject(validation)
                .fieldConfiguration(.newPassword)
                .disableFieldAssistants()
        }
    }
}
