//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI

struct AccountServicesView<Header: View>: View {
    @EnvironmentObject var account: Account

    private var header: Header
    private var button: (any AccountService) -> AnyView
    // TODO Account service may provide different login/signup or a single button (e.g., identity providers)

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
                        if account.accountServices.isEmpty {
                            Text("MISSING_ACCOUNT_SERVICES", bundle: .module)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)

                            Button {
                                UIApplication.shared.open(documentationUrl)
                            } label: {
                                Text("OPEN_DOCUMENTATION", bundle: .module)
                            }
                        } else {
                            ForEach(account.accountServices.indices, id: \.self) { index in
                                button(account.accountServices[index])
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
            UsernamePasswordAccountService(),
            EmailPasswordAccountService()
        ]
        return Account(accountServices: accountServices)
    }()

    static var previews: some View {
        NavigationStack {
            AccountServicesView(header: EmptyView()) { accountService in
                accountService.loginButton
            }
                .navigationTitle(String(localized: "LOGIN", bundle: .module))
        }
            .environmentObject(account)
    }
}
#endif
