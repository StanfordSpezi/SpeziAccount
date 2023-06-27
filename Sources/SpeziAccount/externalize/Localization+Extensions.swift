//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziViews

// TODO move this all to SpeziViews!
extension LocalizedStringResource.BundleDescription {
    static var module: LocalizedStringResource.BundleDescription {
        // TODO our assumption is this works
        .atURL(Bundle.module.bundleURL)
    }
}

struct FieldLocalizationResource {
    let title: LocalizedStringResource
    let placeholder: LocalizedStringResource
}

extension FieldLocalization {
    init(from localization: FieldLocalizationResource) {
        self.init(title: String(localized: localization.title), placeholder: String(localized: localization.placeholder))
    }
}
