//
// Created by Andreas Bauer on 26.06.23.
//

import Foundation
import SwiftUI

struct DefaultKeyPasswordSignUpView<Service: KeyPasswordBasedAccountService>: View {
    var service: Service

    let signUpOptions: SignUpOptions

    @State
    var key: String = ""
    @State
    var password: String = ""
    @State
    var birthday: Date = Date()

    var body: some View {
        form
            .navigationTitle("Sign Up")
        /*
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    header
                        .padding(.bottom, 32)

                    form
                }
                .padding(.horizontal, AccountSetup.Constants.outerHorizontalPadding)
                .frame(minHeight: proxy.size.height)
                .frame(maxWidth: .infinity)
            }
        }
        */
    }

    /// The Views Title and subtitle text.
    @ViewBuilder
    var header: some View {
        // TODO provide customizable with AccountViewStyle!
        Text("Welcome back!") // TODO localize
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .padding(.top, 30)

        Text("Please create an account to do whatever. You may create an account if you don't have one already!") // TODO localize!
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var form: some View {
        Form {
            Text("Thanks for creating a new account and stuff!")

            Section("Credentials") {
                TextField("E-Mail or Username", text: $key)
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
            }

            Section("Personal Data") {
                if signUpOptions.contains(.dateOfBirth) {
                    DateOfBirthPicker(date: $birthday) // TODO pass localization!
                }
            }

            Button(action: {}) {
                Text("Signup")
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .listRowBackground(Color.clear)
                .padding()
                .padding(-34)
        }
    }
}

#if DEBUG
struct DefaultKeyPasswordSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultKeyPasswordSignUpView(service: DefaultUsernamePasswordAccountService(), signUpOptions: [.dateOfBirth])
        }
    }
}
#endif
