//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension LocalizedStringResource.BundleDescription {
    static var module: LocalizedStringResource.BundleDescription = {
        // TODO our assumption is this works?
        .atURL(Bundle.module.bundleURL)
    }()
}


struct DateOfBirthPicker: View {
    private var dateOfBirthTitle: LocalizedStringResource

    @Binding
    private var date: Date

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
            Text(dateOfBirthTitle)
                .fontWeight(.semibold)
        }
    }

    init(
        date: Binding<Date>,
        title: LocalizedStringResource = LocalizedStringResource("UAP_SIGNUP_DATE_OF_BIRTH_TITLE", bundle: .module)
    ) {
        self._date = date
        self.dateOfBirthTitle = title
    }
    
    
    init(date: Binding<Date>, title: String) {
        self.init(date: date, title: LocalizedStringResource(stringLiteral: title))
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
            .environmentObject(UsernamePasswordAccountService())
            .background(Color(.systemGroupedBackground))
    }
}
#endif
