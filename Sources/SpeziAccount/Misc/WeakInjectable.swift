//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// The property wrapper `WeakInjectable` can be used to transparently declare a weak property for a given class type.
@propertyWrapper
public final class WeakInjectable<Type: AnyObject> {
    private weak var weakReference: Type?

    /// Queries if the reference was already injected.
    public var isInjected: Bool {
        weakReference != nil
    }

    /// Access the underlying weak reference.
    /// - Note: This will crash if the underlying value wasn't injected yet.
    public var wrappedValue: Type {
        guard let weakReference else {
            fatalError("Failed to retrieve `\(Type.self)` object from weak reference is not yet present or not present anymore.")
        }

        return weakReference
    }

    public init() {}

    func inject(_ type: Type) {
        self.weakReference = type
    }
}

extension WeakInjectable: Sendable where Type: Sendable {}