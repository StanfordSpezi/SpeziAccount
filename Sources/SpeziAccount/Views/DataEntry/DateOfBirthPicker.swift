//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A `DatePicker` implementation tailored towards entry of a date of birth.
@available(tvOS, unavailable)
struct DateOfBirthPicker: View {
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
    
    
    var body: some View {
        HStack { // swiftlint:disable:this closure_body_length
            DynamicHStack {
                if showPicker {
                    DatePicker(
                        selection: $date,
                        in: dateRange,
                        displayedComponents: .date
                    ) {
                        Text(title)
                    }
                } else {
                    Text(title)
                        .multilineTextAlignment(.leading)
                    
                    if layout == .horizontal {
                        Spacer()
                    }
                    
                    Button(action: addDateAction) {
                        Text("Add Date", bundle: .module)
                            .accessibilityLabel("Add Date of Birth")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding([.leading, .trailing], 20)
                            .padding([.top, .bottom], 7)
                            .frame(maxWidth: 120)
                            .background(
                                osDependentBackgroundRectangle
                                #if os(macOS)
                                    .fill(Color(nsColor: .tertiarySystemFill))
                                #elseif !os(watchOS)
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
        .onPreferenceChange(DynamicLayout.self) { value in
            Task { @MainActor in
                layout = value
            }
        }
    }
    
    private var osDependentBackgroundRectangle: RoundedRectangle {
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 {
            RoundedRectangle(cornerRadius: 32)
        } else {
            RoundedRectangle(cornerRadius: 8)
        }
    }
    
    
    /// Initialize a new `DateOfBirthPicker`.
    /// - Parameters:
    ///   - title: Optionally provide a custom label text.
    ///   - date: A binding to the `Date` state.
    ///   - isRequired: Flag indicating if entry is mandatory. If `false` it adds another `Add Date` button.
    init(
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
@available(tvOS, unavailable)
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
#if !os(macOS) && !os(watchOS)
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

