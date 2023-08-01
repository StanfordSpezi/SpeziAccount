//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public protocol UserIdPasswordAccountService: AccountService, EmbeddableAccountService where ViewStyle: UserIdPasswordAccountSetupViewStyle {
    func login(userId: String, password: String) async throws

    func resetPassword(userId: String) async throws
}


extension UserIdPasswordAccountService where ViewStyle == DefaultUserIdPasswordAccountSetupViewStyle<Self> {
    public var viewStyle: DefaultUserIdPasswordAccountSetupViewStyle<Self> {
        DefaultUserIdPasswordAccountSetupViewStyle(using: self)
    }
}
