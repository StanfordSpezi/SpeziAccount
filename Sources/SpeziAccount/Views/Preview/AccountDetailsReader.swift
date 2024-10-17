//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


/// Read the account details from the SwiftUI environment.
@_spi(TestingSupport)
public struct AccountDetailsReader<Content: View>: View {
    private let content: (Account, AccountDetails) -> Content
    
    @Environment(Account.self)
    private var account

    public var body: some View {
        if let details = account.details {
            content(account, details)
        }
    }
    
    /// Pass in a view builder that receives the account and account details of the environment.
    /// - Parameter bodyClosure: The view builder.
    public init(@ViewBuilder _ content: @escaping (Account, AccountDetails) -> Content) {
        self.content = content
    }
}
