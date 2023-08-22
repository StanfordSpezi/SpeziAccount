//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MissingAccountDetailsWarning: View {
    private var documentationUrl: URL {
        // we may move to a #URL macro once Swift 5.9 is shipping
        // TODO update docs URL!
        guard let docsUrl = URL(string: "https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/createanaccountservice") else {
            fatalError("Failed to construct SpeziAccount Documentation URL. Please review URL syntax!")
        }

        return docsUrl
    }

    var body: some View {
        VStack {
            Text("MISSING_ACCOUNT_DETAILS", bundle: .module)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button(action: {
                UIApplication.shared.open(documentationUrl)
            }) {
                Text("OPEN_DOCUMENTATION", bundle: .module)
            }
                .padding()
        }
    }
}


#if DEBUG
struct MissingAccountDetailsWarning_Previews: PreviewProvider {
    static var previews: some View {
        MissingAccountDetailsWarning()
    }
}
#endif
