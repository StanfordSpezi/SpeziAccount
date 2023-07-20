//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import XCTRuntimeAssertions


// TODO list bundeled ones!
public protocol AccountValueKey: KnowledgeSource<AccountAnchor> where Value: Sendable {}

// TODO docs: requirement is static => be sure when you define a required one! most likely an Optional one!
// TODO maybe "essential" name?
public protocol RequiredAccountValueKey: AccountValueKey, DefaultProvidingKnowledgeSource {}

extension RequiredAccountValueKey {
    public static var defaultValue: Value {
        preconditionFailure("""
                            A required AccountValue wasn't provided by the respective AccountService! \
                            Something went wront with checking the requirements.
                            """)
    }
}
