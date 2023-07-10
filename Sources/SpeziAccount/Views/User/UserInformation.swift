//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

struct UserInformation<Caption: View>: View {
    private let nameComponents: PersonNameComponents
    private let caption: Caption

    public init(name nameComponents: PersonNameComponents, caption: String) where Caption == Text {
        self.init(name: nameComponents) {
            Text(verbatim: caption) // TODO use case to also pass LocalizedStringResource?
        }
    }

    public init(name nameComponents: PersonNameComponents, @ViewBuilder caption: () -> Caption = { EmptyView() }) {
        self.nameComponents = nameComponents
        self.caption = caption()
    }

    var body: some View {
        HStack(spacing: 16) {
            UserProfileView(name: nameComponents)
                .frame(height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(nameComponents.formatted(.name(style: .medium)))
                caption
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.background)
                .shadow(color: .gray, radius: 2)
        )
        .frame(maxWidth: Constants.maxFrameWidth)
    }
}

struct UserInformation_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserInformation(name: try! PersonNameComponents("Andreas Bauer"), caption: "andi.bauer@tum.de")
                .padding(.vertical)

            UserInformation(name: try! PersonNameComponents("Paul Schmiedmayer")) {
                Text("Postdoc (Stanford Byers Center for Biodesign)")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
            .padding()
    }
}
