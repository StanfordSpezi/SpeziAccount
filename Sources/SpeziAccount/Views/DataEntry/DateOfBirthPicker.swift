//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A simple `DatePicker` implementation tailored towards entry of a date of birth.
public struct DateOfBirthPicker: View {
    private let title: LocalizedStringResource
    private let isRequired: Bool

    @Binding private var date: Date
    @State private var dateAdded = false

    @State private var layout: DynamicLayout?

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let startDateComponents = DateComponents(year: 1800, month: 1, day: 1)
        let endDate = Date.now

        guard let startDate = calendar.date(from: startDateComponents) else {
            fatalError("Could not translate \(startDateComponents) to a valid date.")
        }

        return startDate...endDate
    }

    
    /// We want to show the picker if
    ///  - The date is configured to be required.
    ///  - We are NOT entering new date. Showing existing data the user might want to change.
    ///  - If we are entering new data and the user pressed the add button.
    @MainActor private var showPicker: Bool {
        isRequired || dateAdded
    }


    public var body: some View {
        HStack { // swiftlint:disable:this closure_body_length
            DynamicHStack {
                Text(title)
                    .multilineTextAlignment(.leading)

                if layout == .horizontal {
                    Spacer()
                }

                if showPicker {
                    DatePicker(
                        selection: $date,
                        in: dateRange,
                        displayedComponents: .date
                    ) {
                        Text(title)
                    }
                    .labelsHidden()
                } else {
                    Button(action: addDateAction) {
                        Text("ADD_DATE", bundle: .module)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding([.leading, .trailing], 20)
                            .padding([.top, .bottom], 7)
                            .frame(maxWidth: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                #if os(macOS)
                                    .fill(Color(nsColor: .tertiarySystemFill))
                                #else
                                    .fill(Color(uiColor: .tertiarySystemFill))
                                #endif
                            )
                    }
                }
            }

            if layout == .vertical {
                Spacer()
            }
        }
            .accessibilityRepresentation {
                // makes sure the accessibility view spans the whole width, including the label.
                if showPicker {
                    DatePicker(selection: $date, in: dateRange, displayedComponents: .date) {
                        Text(title)
                    }
                } else {
                    Button(action: addDateAction) {
                        Text("VALUE_ADD \(title)", bundle: .module)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .onPreferenceChange(DynamicLayout.self) { value in
                layout = value
            }
    }


    /// Initialize a new `DateOfBirthPicker`.
    /// - Parameters:
    ///   - title: Optionally provide a custom label text.
    ///   - date: A binding to the `Date` state.
    ///   - isRequired: Flag indicating if entry is mandatory. If `false` it adds another `Add Date` button.
    public init(
        _ title: LocalizedStringResource,
        date: Binding<Date>,
        isRequired: Bool = true
    ) {
        self.title = title
        self._date = date
        self.isRequired = isRequired
    }


    private func addDateAction() {
        dateAdded = true
    }
}


#if DEBUG
struct DateOfBirthPicker_Previews: PreviewProvider {
    struct Preview: View {
        @State private var date = Date.now
        private let required: Bool

        var body: some View {
            Form {
                DateOfBirthPicker("Date of Birth", date: $date, isRequired: required)
            }
            VStack {
                DateOfBirthPicker("Date of Birth", date: $date, isRequired: required)
                    .padding(32)
            }
#if !os(macOS)
            .background(Color(uiColor: .systemGroupedBackground))
#endif
        }

        init(required: Bool) {
            self.required = required
        }
    }

    static var previews: some View {
        // preview entering new data.
        Preview(required: false)

        Preview(required: true)
    }
}
#endif
