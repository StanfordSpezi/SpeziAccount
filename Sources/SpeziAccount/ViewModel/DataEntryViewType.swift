//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// The type of parent view a ``DataEntryView`` or ``DataDisplayView`` is displayed in.
public enum DataEntryViewType { // TODO not yet used?
    /// Placed inside a signup view
    case signup
    /// Placed inside an account overview.
    case overview
}
