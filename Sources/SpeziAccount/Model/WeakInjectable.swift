//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// The property wrapper to transparently declare a injectable, weak property for a given class type.
@propertyWrapper
public struct _WeakInjectable<Type: AnyObject> {
    // swiftlint:disable:previous type_name
    // should not appear in documentation nor in autocomplete

    // we split that out into it's own type such that we don't need to make the whole `WeakInjectable` unchecked.
    fileprivate final class UncheckedWeakBox<ObjectType: AnyObject> {
        fileprivate weak var reference: ObjectType?
    }

    private let storage: UncheckedWeakBox<Type> = .init()

    /// Queries if the reference was already injected.
    public var isInjected: Bool {
        storage.reference != nil
    }

    /// Access the underlying weak reference.
    /// - Note: This will crash if the underlying value wasn't injected yet.
    public var wrappedValue: Type {
        guard let weakReference = storage.reference else {
            fatalError("Failed to retrieve `\(Type.self)` object from weak reference is not yet present or not present anymore.")
        }

        return weakReference
    }

    /// Creates a new and empty instance.
    public init() {}

    /// This method injects the weak reference.
    ///
    /// - Parameter type: A reference to the type that is injected into the property wrapper storage.
    public func inject(_ type: Type) {
        self.storage.reference = type
    }
}

extension _WeakInjectable: Sendable where Type: Sendable {}

extension _WeakInjectable.UncheckedWeakBox: @unchecked Sendable where Type: Sendable {}
