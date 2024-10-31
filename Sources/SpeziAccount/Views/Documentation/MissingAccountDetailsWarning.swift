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
        guard let docsUrl = URL(string: "https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/initial-setup") else {
            fatalError("Failed to construct SpeziAccount Documentation URL. Please review URL syntax!")
        }

        return docsUrl
    }

    var body: some View {
        DocumentationInfoView(url: documentationUrl) {
            Label {
                Text("No User Account", bundle: .module)
            } icon: {
                Image(systemName: "richtext.page")
                    .accessibilityHidden(true)
            }
        } description: {
            Text("MISSING_ACCOUNT_DETAILS", bundle: .module)
        }
    }
}


#if DEBUG
#Preview {
    MissingAccountDetailsWarning()
}
#endif
