//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public protocol AccountServiceConfigurationKey: KnowledgeSource<AccountServiceConfiguration.StorageAnchor> where Value == Self {}


extension AccountServiceConfigurationKey {
    func setInto(repository: inout ValueRepository<AccountServiceConfiguration.StorageAnchor>) {
        repository[Self.self] = self
    }
}
