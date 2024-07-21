//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Atomics


/// The property wrapper to transparently declare a injectable, weak property for a given class type.
@propertyWrapper
public struct _WeakInjectable<T: AnyObject> {
    // swiftlint:disable:previous type_name
    // should not appear in documentation nor in autocomplete
    fileprivate final class WeakReference: AtomicReference {
        fileprivate private(set) nonisolated(unsafe) weak var reference: T? // reference counting is atomic, and we never mutate

        init(_ reference: T? = nil) {
            self.reference = reference
        }
    }

    private let storage = ManagedAtomicLazyReference<WeakReference>()

    /// Queries if the reference was already injected.
    public var isInjected: Bool {
        storage.load()?.reference != nil
    }

    /// Access the underlying weak reference.
    /// - Note: This will crash if the underlying value wasn't injected yet.
    public var wrappedValue: T {
        guard let weakReference = storage.load()?.reference else {
            fatalError("Failed to retrieve `\(T.self)` object from weak reference is not yet present or not present anymore.")
        }

        return weakReference
    }

    /// Creates a new and empty instance.
    public init() {}

    /// This method injects the weak reference.
    ///
    /// - Parameter type: A reference to the type that is injected into the property wrapper storage.
    public func inject(_ type: T) {
        let result = self.storage.storeIfNilThenLoad(WeakReference(type))
        assert(result.reference === type, "Cannot inject WeakInjectable multiple times!")
    }
}

extension _WeakInjectable: Sendable where T: Sendable {}

extension _WeakInjectable.WeakReference: Sendable where T: Sendable {}
