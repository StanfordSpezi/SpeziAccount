//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(_Testing)
@_spi(TestingSupport)
import SpeziAccount
import SpeziViews
import SwiftUI


@MainActor
struct EntryViewTests: View {
    @State private var toggle = false
    @State private var integer = 0
    @State private var double = 1.5

    // dismissKeyboard() doesn't work for number pad, therefore we need to workaround that
    @FocusState private var integerField: Bool
    @FocusState private var doubleField: Bool

    var body: some View {
        List {
            Section("Bool") {
                BoolEntryView<MockBoolKey>($toggle)
                ListRow("Bool Value") {
                    Text(toggle ? "true" : "false")
                }
            }

            Section("Integer") {
                FixedWidthIntegerEntryView<MockNumericKey>($integer)
                    .focused($integerField)
                ListRow("Integer Value") {
                    Text(integer.description)
                }
            }

            Section("Double") {
                FloatingPointEntryView<MockDoubleKey>($double)
                    .focused($doubleField)
                ListRow("Double Value") {
                    Text(double.formatted())
                }
            }
        }
            .navigationTitle("Entry Views")
#if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                Button("Dismiss") {
                    integerField = false
                    doubleField = false
                }
            }
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        EntryViewTests()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
