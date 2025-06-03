//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import SpeziFoundation
import SpeziViews
import SwiftUI


private struct DisplayView: SetupDisplayView {
    @Environment(Account.self) private var account
    
    init(_ value: Value?) {
        phoneNumbers = value ?? []
    }
    
    typealias Value = [String]
    private var phoneNumbers: Value
    
    var body: some View {
        Section {
            NavigationLink {
                PhoneNumbersDetailView(phoneNumbers: account.details?.phoneNumbers ?? [])
            } label: {
                HStack {
                    Text("Phone Numbers")
                    Spacer()
                    Group {
                        if let phoneNumber = phoneNumbers.first, phoneNumbers.count == 1 {
                            Text(phoneNumber)
                        } else if phoneNumbers.count > 1 {
                            Text("\(phoneNumbers.count) numbers")
                        } else {
                            EmptyView()
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}


extension AccountDetails {
    public typealias PhoneNumbersArray = [String]

    /// The phone numbers of a user.
    @AccountKey(
        name: "Phone Numbers",
        category: .contactDetails,
        options: .display,
        as: PhoneNumbersArray.self,
        displayView: DisplayView.self
    )
    public var phoneNumbers: PhoneNumbersArray?
}


@KeyEntry(\.phoneNumbers)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier
