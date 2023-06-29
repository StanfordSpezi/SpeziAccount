//
//  SwiftUIView.swift
//  
//
//  Created by Andreas Bauer on 29.06.23.
//

import SpeziViews
import SwiftUI

public struct DefaultUserIdPasswordAccountSummaryView<Service: UserIdPasswordAccountService>: View {
    private let service: Service

    public var body: some View {
        // TODO move this to a UserInformationView!
        HStack(spacing: 16) {
            let name = try! PersonNameComponents("Andreas Bauer")
            UserProfileView(name: name)
                .frame(height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(name.formatted(.name(style: .medium)))
                if let email = .some("andi.bauer@tum.de") {
                    Text(email)
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.background)
                .shadow(color: .gray, radius: 2)
        )
        .frame(maxWidth: AccountSetup.Constants.maxFrameWidth)
    }

    public init(using service: Service) {
        self.service = service
    }
}

struct DefaultUserIdPasswordAccountSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultUserIdPasswordAccountSummaryView(using: DefaultUsernamePasswordAccountService())
            .padding()
    }
}
