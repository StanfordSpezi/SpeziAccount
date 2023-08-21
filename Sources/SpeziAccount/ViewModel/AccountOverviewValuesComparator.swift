//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct AccountOverviewValuesComparator: SortComparator {
    var order: SortOrder = .forward

    private let id = UUID()
    private let accountDetails: AccountDetails
    private let addedAccountValues: CategorizedAccountKeys

    init(accountDetails: AccountDetails, addedAccountValues: CategorizedAccountKeys) {
        self.accountDetails = accountDetails
        self.addedAccountValues = addedAccountValues
    }

    func compare(_ lhs: any AccountValueKey.Type, _ rhs: any AccountValueKey.Type) -> ComparisonResult {
        let lhsContained = lhs.isContained(in: accountDetails)
        let rhsContained = rhs.isContained(in: accountDetails)

        guard !lhsContained && !rhsContained else {
            if lhsContained == rhsContained {
                return .orderedSame
            } else if !rhsContained {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        }

        // this is basically also the "contains" check
        let lhsIndex = addedAccountValues.index(of: lhs)
        let rhsIndex = addedAccountValues.index(of: rhs)

        if let lhsIndex, let rhsIndex {
            if lhsIndex < rhsIndex {
                return .orderedAscending
            } else if lhsIndex > rhsIndex {
                return .orderedDescending
            } else {
                return .orderedSame
            }
        } else if lhsIndex != nil && rhsIndex == nil {
            return .orderedAscending
        } else if lhsIndex == nil && rhsIndex != nil {
            return .orderedDescending
        }

        return .orderedSame
    }
}


extension  AccountOverviewValuesComparator {
    static func == (lhs: AccountOverviewValuesComparator, rhs: AccountOverviewValuesComparator) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
