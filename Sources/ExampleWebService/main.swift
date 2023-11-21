//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OpenAPIRuntime
import OpenAPIVapor
import Vapor

struct AccountService: APIProtocol {
    func createAccount(_ input: Operations.createAccount.Input) async throws -> Operations.createAccount.Output {
        guard case let .json(request) = input.body else { // TODO: this seems to check for optionallity!
            fatalError("HANDLE?")
        }
        let account = Components.Schemas.Account(accountId: "123123", userId: request.userId, details: request.details)
        return .ok(.init(body: .json(account)))
    }
}


let app = Vapor.Application()

let transport = VaporTransport(routesBuilder: app)

let handler = AccountService()

try handler.registerHandlers(on: transport, serverURL: Servers.server1())

try app.run()
