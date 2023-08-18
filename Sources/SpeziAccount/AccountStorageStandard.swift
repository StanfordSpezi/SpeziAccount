//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public protocol AccountStorageStandard: Standard {
    func create(_ userId: UserIdKey, _ details: SignupDetails) async throws

    func modify(_ userId: UserIdKey, _ modifications: AccountModifications) async throws

    func delete(_ userId: UserIdKey) async throws
}
