//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension String {
    // TODO remove!
    init(moduleLocalized: String.LocalizationValue) {
        self.init(localized: moduleLocalized, bundle: .module)
    }
}
