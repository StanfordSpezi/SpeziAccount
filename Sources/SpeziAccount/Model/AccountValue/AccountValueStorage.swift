//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public typealias AccountValueStorage = ValueRepository<AccountAnchor>

public protocol AccountValueStorageContainer {
    var storage: AccountValueStorage { get }
}

public protocol ModifiableAccountValueStorageContainer: AccountValueStorageContainer {
    var storage: AccountValueStorage { get set }
}
