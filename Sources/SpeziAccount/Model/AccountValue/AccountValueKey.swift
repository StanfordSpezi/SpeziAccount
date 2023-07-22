//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI
import XCTRuntimeAssertions


// TODO list bundeled ones!
public protocol AccountValueKey: KnowledgeSource<AccountAnchor> where Value: Sendable, Value: Equatable {
    // TODO docs: Value needs to be Sendable for storage, Equatbale for SignupView!

    associatedtype DataEntry: DataEntryView<Self>

    // TODO its not just signup category! => general value category!
    static var signupCategory: SignupCategory { get }

    // TODO document, one should just use .other if nothing applies!
    static var dataEntryView: GeneralizedDataEntryView<DataEntry> { get } // we could provide a default value, but this way it's explicit!
}

// TODO docs: requirement is static => be sure when you define a required one! most likely an Optional one!
// TODO maybe "essential" name?
public protocol RequiredAccountValueKey: AccountValueKey, DefaultProvidingKnowledgeSource {}


extension AccountValueKey {
    public static var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }

    public static var focusState: String {
        "\(Self.self)"
    }
}


extension RequiredAccountValueKey {
    public static var defaultValue: Value {
        preconditionFailure("""
                            A required AccountValue wasn't provided by the respective AccountService! \
                            Something went wrong with checking the requirements.
                            """)
    }
}
