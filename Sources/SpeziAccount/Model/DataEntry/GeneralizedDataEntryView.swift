//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


// TODO docs, all the ways
public struct GeneralizedDataEntryView<Wrapped: DataEntryView>: View {
    @Environment(\.dataEntryConfiguration)
    var dataEntryConfiguration: DataEntryConfiguration
    @EnvironmentObject
    var signupRequest: SignupRequestBuilder

    @State var signupValue: Wrapped.Key.Value

    public var body: some View {
        buildWrapped()
            .onTapFocus(focusedField: dataEntryConfiguration.focusedField, fieldIdentifier: Wrapped.Key.focusState)
            .onChange(of: signupValue) { newValue in
                // TODO using initial=false basically solves the problem of never submitted values!
                signupRequest.post(for: Wrapped.Key.self, value: newValue)
            }
    }

    public init(initialValue signupValue: Wrapped.Key.Value) {
        self._signupValue = State(wrappedValue: signupValue)
    }

    private func buildWrapped() -> some View {
        let wrapped = Wrapped($signupValue)
        dataEntryConfiguration.hooks.register(Wrapped.Key.self, hook: wrapped.onDataSubmission)
        return wrapped
    }
}


extension AccountValueKey where Value: DefaultInitializable {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: .init())
    }
}

extension AccountValueKey where Value == String {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: "")
    }
}

extension AccountValueKey where Value == Date {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: Date())
    }
}

extension AccountValueKey where Value: AdditiveArithmetic {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        // this catches all the numeric types
        GeneralizedDataEntryView(initialValue: .zero)
    }
}

extension AccountValueKey where Value: ExpressibleByArrayLiteral {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: [])
    }
}

extension AccountValueKey where Value: ExpressibleByDictionaryLiteral {
    public static var dataEntryView: GeneralizedDataEntryView<DataEntry> {
        GeneralizedDataEntryView(initialValue: [:])
    }
}
