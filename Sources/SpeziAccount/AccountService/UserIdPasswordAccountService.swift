//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

// TODO this configuration should be user accessible (userIdType, userIdField config)!
public struct UserIdPasswordServiceConfiguration {
    public static var defaultAccountImage: Image {
        Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical)
    }

    // TODO those two configurations are mandatory for the regular account service even!
    public let name: LocalizedStringResource
    public let image: Image

    // TODO they are not the requirements? you might enter optional values, those are displayed but not required!
    public let signUpRequirements: AccountValueRequirements // TODO replace this with a type that is queryable!

    // TODO localization
    public let userIdType: UserIdType
    public let userIdField: FieldConfiguration

    // TODO login and reset just validates non-empty!
    // TODO a note on client side validation!
    public let userIdSignupValidations: [ValidationRule]
    public let passwordSignupValidations: [ValidationRule]

    public init(
        name: LocalizedStringResource,
        image: Image = defaultAccountImage,
        signUpRequirements: AccountValueRequirements = AccountValueRequirements(), // TODO provide default!
        userIdType: UserIdType = .emailAddress,
        userIdField: FieldConfiguration = .username,
        userIdSignupValidations: [ValidationRule] = [.nonEmpty],
        passwordSignupValidations: [ValidationRule] = [.nonEmpty]
    ) {
        self.name = name
        self.image = image
        self.signUpRequirements = signUpRequirements
        self.userIdType = userIdType
        self.userIdField = userIdField
        self.userIdSignupValidations = userIdSignupValidations
        self.passwordSignupValidations = passwordSignupValidations
    }
}

public protocol UserIdPasswordAccountService: AccountService, EmbeddableAccountService where ViewStyle: UserIdPasswordAccountSetupViewStyle {
    var configuration: UserIdPasswordServiceConfiguration { get }

    func login(userId: String, password: String) async throws

    func signUp(signupRequest: SignupRequest) async throws

    func resetPassword(userId: String) async throws
}

extension UserIdPasswordAccountService {
    public var configuration: UserIdPasswordServiceConfiguration {
        UserIdPasswordServiceConfiguration(name: "Default Account Service") // TODO how to pass this option?
    }
}

extension UserIdPasswordAccountService where ViewStyle == DefaultUserIdPasswordAccountSetupViewStyle<Self> {
    public var viewStyle: DefaultUserIdPasswordAccountSetupViewStyle<Self> {
        DefaultUserIdPasswordAccountSetupViewStyle(using: self)
    }
}
