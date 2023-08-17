//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

public struct VerifiableTextField<FieldLabel: View, FieldFooter: View>: View {
    public enum TextFieldType {
        case text
        case secure
    }

    private let label: FieldLabel
    private let textFieldFooter: FieldFooter
    private let fieldType: TextFieldType

    @Binding private var text: String

    @EnvironmentObject var validationEngine: ValidationEngine

    public var body: some View {
        VStack {
            Group {
                switch fieldType {
                case .text:
                    TextField(text: $text, label: { label })
                case .secure:
                    SecureField(text: $text, label: { label })
                }
            }
                .onSubmit(runValidation)

            HStack {
                ValidationResultsView(results: validationEngine.displayedValidationResults)

                Spacer()

                textFieldFooter
            }
        }
            .onChange(of: text) { _ in
                runValidation()
            }
            .onTapFocus()
    }

    public init(
        _ label: LocalizedStringResource,
        text: Binding<String>,
        type: TextFieldType = .text,
        @ViewBuilder footer: () -> FieldFooter = { EmptyView() }
    ) where FieldLabel == Text {
        self.init(text: text, type: type, label: { Text(label) }, footer: footer)
    }

    public init(
        text: Binding<String>,
        type: TextFieldType = .text,
        @ViewBuilder label: () -> FieldLabel,
        @ViewBuilder footer: () -> FieldFooter = { EmptyView() }
    ) {
        self._text = text
        self.fieldType = type
        self.label = label()
        self.textFieldFooter = footer()
    }

    private func runValidation() {
        validationEngine.submit(input: text, debounce: true)
    }
}

#if DEBUG
struct VerifiableTextField_Previews: PreviewProvider {
    private struct PreviewView: View {
        @State var text = ""
        @StateObject var engine = ValidationEngine(rules: .nonEmpty)

        var body: some View {
            VerifiableTextField(text: $text) {
                Text("Password Text")
            } footer: {
                Text("Some Hint")
                    .font(.footnote)
            }
                .environmentObject(engine)
        }
    }
    static var previews: some View {
        Form {
            PreviewView()
        }

        PreviewView()
    }
}
#endif
