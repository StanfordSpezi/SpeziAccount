//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


struct AccountServiceEnvironmentKey: EnvironmentKey {
    static var defaultValue: (any AccountServiceNew)?
}

extension EnvironmentValues {
    var anyAccountService: (any AccountServiceNew)? {
        get {
            self[AccountServiceEnvironmentKey.self]
        }
        set {
            self[AccountServiceEnvironmentKey.self] = newValue
        }
    }
}

@propertyWrapper
struct AccountServiceProperty<Service: AccountServiceNew>: DynamicProperty { // TODO name clash!
    @Environment(\.anyAccountService)
    private var anyAccountService

    // TODO we use EnvironmentObject to allow to trigger updates????
    // @EnvironmentObject
    // private var accountServiceObject: Service

    @MainActor
    var wrappedValue: Service {
        // TODO refactor to guard!
        if let anyService = anyAccountService {
            guard let typedService = anyService as? Service else {
                // fair to raise an fatal error, environment object does the same!
                fatalError("Tried accessing AccountService from the Environment expecting \(Service.self) but received type \(type(of: anyService))!")
            }

            return typedService
        }

        fatalError("Failed to inject account service!")
    }
}


extension AccountServiceNew {
    func injectAccountService<V: View>(into view: V) -> some View {
        /*
         // TODO how to handle observable objects?
        if let observable = self as? any AccountServiceNew & ObservableObject {
            return observable
                .injectAccountServiceAsEnvironmentObject(into: view)
                .environment(\.anyAccountService, self)
        }
        */

        return view
            .environment(\.anyAccountService, self)
    }
}

extension AccountServiceNew where Self: ObservableObject {
    func injectAccountServiceAsEnvironmentObject<V: View>(into view: V) -> some View {
        print("Injecting \(Self.self)") // TODO remove debug!
        return view
            .environmentObject(self) // TODO test that this works!!
    }
}
/*
 // TODO we might consider adding that back?
extension AccountServiceNew {
    func injectViewStyle<V: View>(into view: V) -> some View {
        print("Injecting \(Self.self)") // TODO remove debug!
        return view
            .environmentObject(self) // TODO test that this works!!
            // TODO how would the default implementation of KeyPasswordBasedAccountServiceStyle access KeyPasswordBasedAccountService
    }
}
*/
