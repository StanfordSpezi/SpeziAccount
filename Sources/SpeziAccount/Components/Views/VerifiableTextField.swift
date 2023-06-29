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
    private let validationRules: [ValidationRule]

    @Binding private var text: String
    @Binding private var inputValid: Bool

    @State private var validationResults: [String] = []
    @State private var debounceTask: Task<Void, Never>? {
        willSet {
            debounceTask?.cancel()
        }
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
                .onSubmit(runValidation) // TODO trigger onSubmit with focus change!

            HStack {
                VStack(alignment: .leading) {
                    ForEach(validationResults, id: \.self) { message in
                        Text(message)
                            .fixedSize(horizontal: false, vertical: true) // TODO required?
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
            .onTapFocus() // TODO what does this do?
    }

    public init(
        type: TextFieldType = .text,
        text: Binding<String>,
        valid: Binding<Bool>,
        validationRules: [ValidationRule] = [], // TODO pass default empty rule!
        @ViewBuilder label: () -> FieldLabel
    ) where FieldFooter == EmptyView {
        self.init(type: type, text: text, valid: valid, label: label, footer: { EmptyView() })
    }

    public init(
        type: TextFieldType = .text,
        text: Binding<String>,
        valid: Binding<Bool>,
        validationRules: [ValidationRule] = [], // TODO pass default empty rule!
        @ViewBuilder label: () -> FieldLabel,
        @ViewBuilder footer: () -> FieldFooter
    ) {
        self._text = text
        self.fieldType = type
        self._inputValid = valid
        self.validationRules = validationRules
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
                validationResults = validationRules.compactMap {
                    $0.validate(text)
                }

                print("validation is run: \(validationResults)")

                inputValid = validationResults.isEmpty // TODO isEmpty check is also a validationResult
            }

            self.debounceTask = nil
        }
    }
}

#if DEBUG
struct VerifiableTextField_Previews: PreviewProvider {
    private struct PreviewView: View {
        @State var text = ""
        @State var valid = false

        var body: some View {
            VerifiableTextField(text: $text, valid: $valid, validationRules: [.lettersOnly]) {
                Text("Text")
            } footer: {
                Text("Some Hint")
                    .font(.footnote)
            }
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
