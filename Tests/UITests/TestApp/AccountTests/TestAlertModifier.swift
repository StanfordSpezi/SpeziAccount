//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@Observable
final class TestAlertModel: Sendable {
    @MainActor var presentingAlert = false
    @MainActor var continuation: CheckedContinuation<Void, Never>?

    init() {}
}


struct TestAlertModifier: ViewModifier {
    @Environment(TestAlertModel.self) var model

    @State private var isActive = false

    @MainActor var isPresented: Binding<Bool> {
        Binding {
            model.presentingAlert && isActive
        } set: { newValue in
            model.presentingAlert = newValue
        }
    }


    func body(content: Content) -> some View {
        content
            .onAppear {
                isActive = true
            }
            .onDisappear {
                isActive = false
            }
            .alert("Security Alert", isPresented: isPresented, presenting: model.continuation) { continuation in
                Button("Dismiss") {
                    continuation.resume()
                }
            }
    }
}
