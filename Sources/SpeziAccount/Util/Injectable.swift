//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// The property wrapper to transparently declare a injectable property for a given type.
@propertyWrapper
public class Injectable<Type> {
    private var storage: Type?

    /// Queries if the reference was already injected.
    public var isInjected: Bool {
        storage != nil
    }

    /// Access the underlying type.
    /// - Note: This will crash if the underlying value wasn't injected yet.
    public var wrappedValue: Type {
        guard let weakReference = storage else {
            fatalError("Failed to retrieve `\(Type.self)` object from weak reference is not yet present or not present anymore.")
        }

        return weakReference
    }

    /// Creates a new and empty instance.
    public init() {}

    /// This method injects the instance.
    ///
    /// - Parameter type: A reference to the type that is injected into the property wrapper storage.
    public func inject(_ type: Type) {
        self.storage = type
    }
}

extension Injectable: @unchecked Sendable where Type: Sendable {}
