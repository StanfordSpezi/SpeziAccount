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
    @State private var debounceTask: Task<Void, Never>? {
        willSet {
            debounceTask?.cancel()
        }
    }

    private var displayedValidationResults: [FailedValidationResult] {
        // we want the behavior that we won't display any validation results if the user
        // erases the whole field. We do this by just calling `runValidationOnSubmit` on commit.
        // However, if ,e.g., a button triggers a `runValidation` we still want to show the message
        // even on an empty field.
        validationEngine.inputValid ? [] : validationEngine.validationResults
    }

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
                VStack(alignment: .leading) {
                    ForEach(displayedValidationResults) { result in
                        Text(result.message)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .font(.footnote)
                .foregroundColor(.red)
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
        debounceTask = Task {
            // Wait 0.5 seconds until you start the validation.
            try? await Task.sleep(for: .seconds(0.2))

            guard !Task.isCancelled else {
                return
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                validationEngine.runValidationOnSubmit(input: text)
            }

            self.debounceTask = nil
        }
    }
}

#if DEBUG
struct VerifiableTextField_Previews: PreviewProvider {
    private struct PreviewView: View {
        @State var text = ""
        @StateObject var engine = ValidationEngine(rules: .asciiLettersOnly)

        var body: some View {
            VerifiableTextField(text: $text) {
                Text("Text")
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
