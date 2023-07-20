//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DateOfBirthPicker: View {
    private let titleLocalization: LocalizedStringResource

    @Binding private var date: Date

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let startDateComponents = DateComponents(year: 1900, month: 1, day: 1)
        let endDate = Date.now

        guard let startDate = calendar.date(from: startDateComponents) else {
            fatalError("Could not translate \(startDateComponents) to a valid date.")
        }

        return startDate...endDate
    }

    var body: some View {
        DatePicker(
            selection: $date,
            in: dateRange,
            displayedComponents: [.date]
        ) {
            Text(titleLocalization)
                .fontWeight(.semibold)
        }
            // TODO birthday text content type?
    }

    init(
        date: Binding<Date>,
        title: LocalizedStringResource = LocalizedStringResource("UAP_SIGNUP_DATE_OF_BIRTH_TITLE", bundle: .atURL(from: .module))
    ) {
        self._date = date
        self.titleLocalization = title
    }

    init(date: Binding<Date>, title: String.LocalizationValue) {
        self.init(date: date, title: LocalizedStringResource(title))
    }
}


#if DEBUG
struct DateOfBirthPicker_Previews: PreviewProvider {
    @State private static var date = Date.now


    static var previews: some View {
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
#endif
