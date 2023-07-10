//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public class MockSimpleAccountService: AccountService {
    @AccountReference private var account: Account

    public var viewStyle: some AccountSetupViewStyle { // TODO one needs to
        DefaultAccountSetupViewStyle(using: self)
    }

    public func logout() async throws {}
}

// TODO rename to Mock... (PR desc: Current impl provided as is, and are more like Mock implementations, => replace with protocols and Mock implementations!
public class DefaultUsernamePasswordAccountService: UserIdPasswordAccountService {
    @AccountReference private var account: Account

    public func login(userId: String, password: String) async throws {
        print("login \(userId) \(password)")
        try? await Task.sleep(nanoseconds: 1000_000_000)

        let details = AccountDetails.Builder()
            .add(UserIdAccountValueKey.self, value: userId)
            .add(NameAccountValueKey.self, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
            .build(owner: self)
        await account.supplyUserInfo(details)
    }

    public func signUp(signupRequest: SignupRequest) async throws {
        print("signup \(signupRequest)")
        try? await Task.sleep(nanoseconds: 1000_000_000)

        let details = AccountDetails.Builder(from: signupRequest)
            .remove(PasswordAccountValueKey.self)
            .build(owner: self)
        await account.supplyUserInfo(details)
    }

    public func resetPassword(userId: String) async throws {
        print("resetPassword \(userId)")
        try? await Task.sleep(nanoseconds: 1000_000_000)
    }

    public func logout() async throws {
        print("logout")
        try? await Task.sleep(nanoseconds: 1000_000_000)
        await account.removeUserInfo()
    }
}
