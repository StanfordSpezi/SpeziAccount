//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public struct UserIdPasswordServiceConfiguration {
    public static var defaultAccountImage: Image {
        Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical)
    }

    // TODO those two configurations are mandatory for the regular account service even!
    public let name: LocalizedStringResource
    public let image: Image

    public let signUpOptions: SignUpOptions

    // TODO localization
    public let userIdField: FieldConfiguration

    // TODO login and reset just validates non-empty!
    // TODO a note on client side validation!
    public let userIdSignupValidations: [ValidationRule]
    public let passwordSignupValidations: [ValidationRule]

    public init(
        name: LocalizedStringResource,
        image: Image = defaultAccountImage,
        signUpOptions: SignUpOptions = .default,
        userIdField: FieldConfiguration = .username,
        userIdSignupValidations: [ValidationRule] = [.nonEmpty],
        passwordSignupValidations: [ValidationRule] = [.nonEmpty]
    ) {
        self.name = name
        self.image = image
        self.signUpOptions = signUpOptions
        self.userIdField = userIdField
        self.userIdSignupValidations = userIdSignupValidations
        self.passwordSignupValidations = passwordSignupValidations
    }
}

public protocol UserIdPasswordAccountService: AccountService, EmbeddableAccountService where ViewStyle: UserIdPasswordAccountSetupViewStyle {
    var configuration: UserIdPasswordServiceConfiguration { get }

    func login(userId: String, password: String) async throws

    // TODO ability to abstract SignUpValues
    func signUp(signUpValues: SignUpValues) async throws // TODO refactor SignUpValues property names!

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
