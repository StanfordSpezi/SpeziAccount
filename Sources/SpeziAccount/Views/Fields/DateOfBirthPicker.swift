//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A simple `DatePicker` implementation tailored towards entry of a date of birth.
public struct DateOfBirthPicker: DataEntryView {
    public typealias Key = DateOfBirthKey

    private let titleLocalization: LocalizedStringResource

    @Environment(Account.self) private var account
    @Environment(\.accountViewType) private var viewType

    @Binding private var date: Date
    @State private var dateAdded = false

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
    private var showPicker: Bool {
        account.configuration[Key.self]?.requirement == .required
            || viewType?.enteringNewData == false
            || dateAdded
    }


    public var body: some View {
        HStack {
            Text(titleLocalization)
                .multilineTextAlignment(.leading)
            Spacer()

            if showPicker {
                DatePicker(
                    selection: $date,
                    in: dateRange,
                    displayedComponents: .date
                ) {
                    Text(titleLocalization)
                }
                    .labelsHidden()
            } else {
                Button(action: addDateAction) {
                    Text("ADD_DATE", bundle: .module)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .frame(width: 110, height: 34)
                }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: .tertiarySystemFill))
                    )
            }
        }
            .accessibilityRepresentation {
                // makes sure the accessibility view spans the whole width, including the label.
                if showPicker {
                    DatePicker(selection: $date, in: dateRange, displayedComponents: .date) {
                        Text(titleLocalization)
                    }
                } else {
                    Button(action: addDateAction) {
                        Text("VALUE_ADD \(titleLocalization)", bundle: .module)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
    }


    /// Initialize a new `DateOfBirthPicker`.
    /// - Parameters:
    ///   - date: A binding to the `Date` state.
    ///   - customTitle: Optionally provide a custom label text.
    public init(
        date: Binding<Date>,
        title customTitle: LocalizedStringResource? = nil
    ) {
        self._date = date
        self.titleLocalization = customTitle ?? DateOfBirthKey.name
    }

    public init(_ value: Binding<Date>) {
        self.init(date: value)
    }


    private func addDateAction() {
        dateAdded = true
    }
}


#if DEBUG
struct DateOfBirthPicker_Previews: PreviewProvider {
    struct Preview: View {
        @State private var date = Date.now

        var body: some View {
            VStack {
                Form {
                    DateOfBirthPicker(date: $date)
                }
                    .frame(height: 200)
                DateOfBirthPicker(date: $date)
                    .padding(32)
            }
                .background(Color(.systemGroupedBackground))
        }
    }

    static var previews: some View {
        // preview entering new data.
        Preview()
            .environment(Account(MockUserIdPasswordAccountService()))
            .environment(\.accountViewType, .signup)

        // preview entering new data but displaying existing data.
        Preview()
            .environment(Account(MockUserIdPasswordAccountService()))
            .environment(\.accountViewType, .overview(mode: .existing))

        // preview entering new data but required.
        Preview()
            .environment(Account(MockUserIdPasswordAccountService(), configuration: [.requires(\.dateOfBirth)]))
            .environment(\.accountViewType, .signup)
    }
}
#endif
