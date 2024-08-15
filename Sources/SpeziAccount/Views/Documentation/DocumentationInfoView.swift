//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


struct DocumentationInfoView: View {
    private let infoText: Text
    private let url: URL


    var body: some View {
        VStack {
            infoText
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button {
#if os(macOS)
                NSWorkspace.shared.open(url)
#else
                UIApplication.shared.open(url)
#endif
            } label: {
                Text("OPEN_DOCUMENTATION", bundle: .module)
            }
                .padding()
        }
    }


    init(infoText: Text, url: URL) {
        self.infoText = infoText
        self.url = url
    }


    init(infoText: LocalizedStringResource, url: URL) {
        self.infoText = Text(infoText)
        self.url = url
    }
}


#Preview {
    guard let url = URL(string: "https://google.com") else {
        return EmptyView()
    }
    return DocumentationInfoView(infoText: Text(verbatim: "This is an info text."), url: url)
}
