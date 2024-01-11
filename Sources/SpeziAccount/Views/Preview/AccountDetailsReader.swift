//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


struct AccountDetailsReader<Content: View>: View {
    @Environment(Account.self) var account
    private let bodyClosure: (Account, AccountDetails) -> Content

    var body: some View {
        if let details = account.details {
            bodyClosure(account, details)
        }
    }

    init(@ViewBuilder _ bodyClosure: @escaping (Account, AccountDetails) -> Content) {
        self.bodyClosure = bodyClosure
    }
}
