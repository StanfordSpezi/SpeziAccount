//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


struct DocumentationInfoView<Label: View, Description: View>: View {
    private let label: Label
    private let description: Description
    private let url: URL


    var body: some View {
        ContentUnavailableView {
            label
        } description: {
            description
        } actions: {
            Button {
#if os(macOS)
                NSWorkspace.shared.open(url)
#else
                UIApplication.shared.open(url)
#endif
            } label: {
                Text("OPEN_DOCUMENTATION", bundle: .module)
            }
        }
    }


    init(url: URL, @ViewBuilder label: () -> Label, @ViewBuilder description: () -> Description) {
        self.url = url
        self.label = label()
        self.description = description()
    }
}


#Preview {
    guard let url = URL(string: "https://google.com") else {
        return EmptyView()
    }
    return DocumentationInfoView(url: url) {
        Text(verbatim: "This is an info text.")
    } description: {
        Text(verbatim: "This is more description")
    }
}
