//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi

// TODO can we split out some functionality into different targets? (e.g. AccountService side vs User side?

public protocol AccountServiceProvider: Component {
    associatedtype Service: AccountService

    var accountService: Service { get } // TODO one might provide multiple account services!
}

// TODO remove!
public class ExampleConfiguration<ComponentStandard: Standard>: AccountServiceProvider {
    public var accountService: MockSimpleAccountService {
        MockSimpleAccountService()
    }
}

// TODO move somewhere else!
@resultBuilder
public enum AccountServiceProviderBuilder<S: Standard> {
    public static func buildExpression<Provider: AccountServiceProvider>(
        _ expression: @autoclosure @escaping () -> Provider
    ) -> [any ComponentDependency<S>] where Provider.ComponentStandard == S {
        [_DependencyPropertyWrapper<Provider, S>(wrappedValue: expression())]
    }

    // TODO support conditionals etc!

    public static func buildBlock(_ components: [any ComponentDependency<S>]...) -> [any ComponentDependency<S>] {
        var result: [any ComponentDependency<S>] = []

        for componentArray in components {
            result.append(contentsOf: componentArray)
        }

        return result
    }
}

public final class AccountConfiguration<ComponentStandard: Standard>: Component, ObservableObjectProvider {
    @DynamicDependencies var dynamicDependencies: [any Component<ComponentStandard>]


    private var account: Account?

    public var observableObjects: [any ObservableObject] {
        guard let account else {
            fatalError("Tried to access ObservableObjectProvider before \(Self.self).configure() was called")
        }

        return [account]
    }

    public init() {
        self._dynamicDependencies = DynamicDependencies(componentProperties: [])
    }

    public init(@AccountServiceProviderBuilder<ComponentStandard> _ components: @escaping () -> [any ComponentDependency<ComponentStandard>]) {
        self._dynamicDependencies = DynamicDependencies(componentProperties: components())
    }

    public func configure() {
        let accountServices: [any AccountService] = dynamicDependencies.map { dependency in
            guard let serviceProvider = dependency as? any AccountServiceProvider else {
                fatalError("Reached inconsistent state where dynamic dependency isn't a AccountServiceProvider: \(dependency)")
            }

            return serviceProvider.accountService
        }

        account = Account(services: accountServices)
    }
}
