//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SwiftUI


/*
public class DataEntryValidationClosures { // TODO part of the view model
    public struct Entry {
        public let validationClosure: () -> DataValidationResult
        public let focusStateValue: String
    }


    // we use an ordered dictionary to preserve the order in which the user is corrected on invalid input
    // (e.g. focusState should move to the first input field that is incorrect input!)
    private var storage: OrderedDictionary<ObjectIdentifier, Entry> = [:]


    public func register<Key: AccountValueKey>(_ key: Key.Type, validation: @escaping () -> DataValidationResult) {
        storage[key.id] = Entry(validationClosure: validation, focusStateValue: key.focusState)
    }

    func clear() {
        storage = [:]
    }

    func runAlLValidationsReturningFailed() -> [String] {
        self.compactMap { entry in
            let result = entry.validationClosure()
            switch result {
            case .success:
                return nil
            case .failed:
                return entry.focusStateValue
            case let .failedAtField(focusedField):
                return focusedField
            }
        }
    }
}


extension DataEntryValidationClosures: Collection {
    public typealias Index = OrderedDictionary<ObjectIdentifier, Entry>.Index

    public var startIndex: Index {
        storage.values.startIndex
    }

    public var endIndex: Index {
        storage.values.endIndex
    }

    public func index(after index: Index) -> Index {
        storage.values.index(after: index)
    }


    public subscript(position: Index) -> Entry {
        storage.values[position]
    }
}

 */
