//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension AccountService {
    /// A property wrapper that can be used within ``AccountService`` instances to request
    /// access to the ``Account`` instance.
    ///
    /// Below is a short code example on how to use this property wrapper:
    /// ```swift
    /// public actor MyAccountService: AccountService {
    ///     @AccountReference var account
    /// }
    /// ```
    public typealias AccountReference = WeakInjectable<Account>

    /// A property wrapper that can be used within ``AccountService`` instances to request
    /// access to a ``AccountStorageStandard`` instance.
    ///
    /// Below is a short code example on how to use this property wrapper:
    /// ```swift
    /// public actor MyAccountService: AccountService {
    ///     @AccountStorage var storage
    /// }
    /// ```
    public typealias AccountStorage = Injectable<any AccountStorageStandard>
}
