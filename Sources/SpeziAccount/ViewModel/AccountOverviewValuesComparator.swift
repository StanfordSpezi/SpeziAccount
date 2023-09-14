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
    private let addedAccountKeys: CategorizedAccountKeys
    private let removedAccountKeys: CategorizedAccountKeys

    init(details: AccountDetails, added: CategorizedAccountKeys, removed: CategorizedAccountKeys) {
        self.accountDetails = details
        self.addedAccountKeys = added
        self.removedAccountKeys = removed
    }

    func compare(_ lhs: any AccountKey.Type, _ rhs: any AccountKey.Type) -> ComparisonResult {
        let lhsContained = accountDetails.contains(lhs) && !removedAccountKeys.contains(lhs)
        let rhsContained = accountDetails.contains(rhs) && !removedAccountKeys.contains(rhs)

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
        let lhsIndex = addedAccountKeys.index(of: lhs)
        let rhsIndex = addedAccountKeys.index(of: rhs)

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
