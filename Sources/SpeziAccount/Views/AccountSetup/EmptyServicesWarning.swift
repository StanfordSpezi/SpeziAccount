//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


struct EmptyServicesWarning: View {
    private var documentationUrl: URL {
        // we may move to a #URL macro once Swift 5.9 is shipping
        guard let docsUrl = URL(string: "https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/initial-setup") else {
            fatalError("Failed to construct SpeziAccount Documentation URL. Please review URL syntax!")
        }

        return docsUrl
    }

    var body: some View {
        VStack {
            Text("MISSING_ACCOUNT_SERVICES", bundle: .module)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button(action: {
#if os(macOS)
                NSWorkspace.shared.open(documentationUrl)
#else
                UIApplication.shared.open(documentationUrl)
#endif
            }) {
                Text("OPEN_DOCUMENTATION", bundle: .module)
            }
                .padding()
        }
    }
}


#if DEBUG
struct EmptyServicesWarning_Previews: PreviewProvider {
    static var previews: some View {
        EmptyServicesWarning()
    }
}
#endif
