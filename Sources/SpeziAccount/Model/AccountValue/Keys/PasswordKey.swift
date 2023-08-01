//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct PasswordKey: RequiredAccountValueKey {
    public typealias Value = String

    public static let signupCategory: SignupCategory = .credentials
}


extension AccountValueKeys {
    // TODO is password update special (requires existing knowledge?)
    public var password: PasswordKey.Type {
        PasswordKey.self
    }
}


extension SignupRequest {
    public var password: PasswordKey.Value {
        storage[PasswordKey.self]
    }
}


// MARK: - UI
extension PasswordKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = PasswordKey

        @Environment(\.dataEntryConfiguration)
        var dataEntryConfiguration: DataEntryConfiguration

        @Binding private var password: Value


        public init(_ value: Binding<Value>) {
            self._password = value
        }

        public var body: some View {
            VerifiableTextField("UP_PASSWORD".localized(.module), text: $password, type: .secure)
                .fieldConfiguration(.newPassword)
                .disableFieldAssistants()
        }
    }
}
