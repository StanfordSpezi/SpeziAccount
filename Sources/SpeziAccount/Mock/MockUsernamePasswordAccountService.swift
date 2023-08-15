//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO docs! rename UserId => make userid type controllable!
public actor MockUsernamePasswordAccountService: UserIdPasswordAccountService {
    private struct AccountValueUpdater: AccountValueVisitor {
        var detailsBuilder: AccountDetails.Builder

        init(details: AccountDetails) {
            self.detailsBuilder = .init(from: details)
        }

        func visit<Key>(_ key: Key.Type, _ value: Key.Value) where Key: AccountValueKey {
            print("Setting \(Key.self) to \(value)")
            detailsBuilder.set(key, value: value)
        }

        func buildFinal() -> AccountDetails.Builder {
            detailsBuilder
        }
    }

    private struct AccountValueRemover: AccountValueVisitor {
        var detailsBuilder: AccountDetails.Builder

        init(builder detailsBuilder: AccountDetails.Builder) {
            self.detailsBuilder = detailsBuilder
        }

        func visit<Key>(_ key: Key.Type, _ value: Key.Value) where Key: AccountValueKey {
            print("Removing \(key) with old value \(value)")
            detailsBuilder.remove(key)
        }

        func buildFinal() -> AccountDetails.Builder {
            detailsBuilder
        }
    }

    @AccountReference private var account: Account


    public let configuration = AccountServiceConfiguration(name: "Mock AccountService")

    public init() {}

    public func login(userId: String, password: String) async throws {
        print("Mock Login: \(userId) \(password)")
        try? await Task.sleep(for: .seconds(1))

        let details = AccountDetails.Builder()
            .set(\.userId, value: userId)
            .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
            .build(owner: self)
        await account.supplyUserDetails(details)
    }

    public func signUp(signupDetails: SignupDetails) async throws {
        print("Mock Signup: \(signupDetails)")
        try? await Task.sleep(for: .seconds(1))

        let details = AccountDetails.Builder(from: signupDetails)
            .remove(\.password)
            .build(owner: self)
        await account.supplyUserDetails(details)
    }

    public func resetPassword(userId: String) async throws {
        print("Mock ResetPassword: \(userId)")
        try? await Task.sleep(for: .seconds(1))
    }

    public func logout() async throws {
        print("Mock Logout")
        try? await Task.sleep(for: .seconds(1))
        await account.removeUserDetails()
    }

    public func delete() async throws {
        print("Mock Remove Account")
        try? await Task.sleep(for: .seconds(1))
        await account.removeUserDetails()
    }

    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        guard let details = await account.details else {
            return
        }

        try? await Task.sleep(for: .seconds(1))

        // TODO can this API surface be more elegant?
        let builder = modifications.modifiedDetails
            .acceptAll(AccountValueUpdater(details: details))
        let finalBuilder = modifications.removedAccountDetails
            .acceptAll(AccountValueRemover(builder: builder))

        await account.supplyUserDetails(finalBuilder.build(owner: self))
    }
}
