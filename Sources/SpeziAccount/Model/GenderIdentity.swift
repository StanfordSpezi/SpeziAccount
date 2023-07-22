//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


/// Describes the self-identified gender identity
public enum GenderIdentity: Int, Sendable, CaseIterable, Identifiable, Hashable {
    /// Self-identify as female
    case female
    /// Self-identify as male
    case male
    /// Self-identify as transgender
    case transgender
    /// Self-identify as non-binary
    case nonBinary
    /// Prefer not to state the self-identified gender
    case preferNotToState
    
    
    public var id: RawValue {
        rawValue
    }
}


extension GenderIdentity: DefaultInitializable {
    public init() {
        self = .preferNotToState
    }
}


extension GenderIdentity: CustomLocalizedStringResourceConvertible {
    private var localizationValue: String.LocalizationValue {
        switch self {
        case .female:
            return "GENDER_IDENTITY_FEMALE"
        case .male:
            return "GENDER_IDENTITY_MALE"
        case .transgender:
            return "GENDER_IDENTITY_TRANSGENDER"
        case .nonBinary:
            return "GENDER_IDENTITY_NON_BINARY"
        case .preferNotToState:
            return "GENDER_IDENTITY_PREFER_NOT_TO_STATE"
        }
    }

    public var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(localizationValue, bundle: .atURL(from: .module))
    }
}
