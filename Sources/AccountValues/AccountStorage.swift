//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A `ValueRepository` that stores `KnowledgeSource`s anchored to the ``AccountAnchor``.
///
/// This is the underlying storage type user in, e.g., ``AccountDetails``, ``SignupDetails`` or ``ModifiedAccountDetails``.
public typealias AccountStorage = ValueRepository<AccountAnchor>
