//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI

struct AccountServicesView<Header: View>: View {
    @EnvironmentObject var account: Account

    private var header: Header
    private var button: (any AccountService) -> AnyView

    private var documentationUrl: URL {
        // we may move to a #URL macro once Swift 5.9 is shipping
        guard let docsUrl = URL(string: "https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/createanaccountservice") else {
            fatalError("Failed to construct SpeziAccount Documentation URL. Please review URL syntax!")
        }

        return docsUrl
    }
    
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    header
                    Spacer(minLength: 0)
                    VStack(spacing: 16) {
                        if account.registeredAccountServices.isEmpty {
                            Text("MISSING_ACCOUNT_SERVICES", bundle: .module)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)

                            Button {
                                UIApplication.shared.open(documentationUrl)
                            } label: {
                                Text("OPEN_DOCUMENTATION", bundle: .module)
                            }
                        } else {
                            ForEach(account.registeredAccountServices.indices, id: \.self) { index in
                                // TODO iterating over protocols foreach crashes xcode preview!
                                button(account.registeredAccountServices[index])
                            }
                        }
                    }
                        .padding(16)
                }
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    
    init(button: @escaping (any AccountService) -> AnyView) where Header == EmptyView {
        self.header = EmptyView()
        self.button = button
    }
    
    init(header: Header, button: @escaping (any AccountService) -> AnyView) {
        self.header = header
        self.button = button
    }
}


#if DEBUG
struct AccountServicesView_Previews: PreviewProvider {
    @StateObject private static var account: Account = {
        let accountServices: [any AccountService] = [
            //UsernamePasswordAccountService(),
            // EmailPasswordAccountService()
        ]
        return Account(services: accountServices)
    }()

    static var previews: some View {
        NavigationStack {
            AccountServicesView(header: EmptyView()) { accountService in
                AnyView(Text("<Login Button>"))
                // accountService.loginButton
            }
                .navigationTitle(String(localized: "LOGIN", bundle: .module))
        }
            .environmentObject(account)
    }
}
#endif
