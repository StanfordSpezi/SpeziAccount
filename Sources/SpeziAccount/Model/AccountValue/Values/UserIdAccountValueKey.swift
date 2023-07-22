//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


// TODO rename everything => "UserIdKey"?
public struct UserIdAccountValueKey: RequiredAccountValueKey {
    public typealias Value = String

    public static let signupCategory: SignupCategory = .credentials
}


extension AccountValueKeys {
    // TODO is userId update special? requires verification and stuff?
    public var userId: UserIdAccountValueKey.Type {
        UserIdAccountValueKey.self
    }
}


extension AccountValueStorageContainer {
    public var userId: UserIdAccountValueKey.Value {
        storage[UserIdAccountValueKey.self]
    }
}

// TODO one might not change the user id!
extension ModifiableAccountValueStorageContainer {
    public var userId: UserIdAccountValueKey.Value {
        get {
            storage[UserIdAccountValueKey.self]
        }
        set {
            storage[UserIdAccountValueKey.self] = newValue
        }
    }
}


// MARK: - UI
extension UserIdAccountValueKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = UserIdAccountValueKey

        @Environment(\.dataEntryConfiguration)
        var dataEntryConfiguration: DataEntryConfiguration

        @Binding public var userId: Value

        @StateObject var validation = ValidationEngine()

        public init(_ value: Binding<Value>) {
            self._userId = value
        }

        public var body: some View {
            VerifiableTextField(dataEntryConfiguration.serviceConfiguration.userIdType.localizedStringResource, text: $userId)
                .environmentObject(validation)
                .fieldConfiguration(dataEntryConfiguration.serviceConfiguration.userIdField)
                .disableFieldAssistants()
                .onAppear {
                    // TODO this is still a bit nasty? => just make the whole validation thing a modifier!!
                    validation.validationRules = dataEntryConfiguration.serviceConfiguration.userIdSignupValidations
                }
        }

        public func onDataSubmission() -> DataValidationResult {
            validation.runValidation(input: userId)

            return validation.inputValid ? .success : .failed
        }
    }
}
