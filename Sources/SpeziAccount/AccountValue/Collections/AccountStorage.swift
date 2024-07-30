//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A `ValueRepository` that stores `KnowledgeSource`s anchored to the `AccountAnchor`.
///
/// This is the underlying storage type used ``AccountDetails``. All elements are tied to the ``AccountAnchor``.
typealias AccountStorage = ValueRepository<AccountAnchor>
