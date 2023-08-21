//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A `DataEntryConfiguration` provides access to the configuration state of the parent view of a ``DataEntryView`` or ``DataDisplayView``.
///
/// Data entry views include built-in views like ``SignupForm`` or ``AccountOverview`.
/// In subviews like implementations of ``DataEntryView`` you can access the parents views
/// configuration using the `@EnvironmentObject` property wrapper.
///
/// ```swift
/// struct SomeDataEntryView: View {
///     @EnvironmentObject var dataEntryConfiguration: DataEntryConfiguration
///
///     var body: some View {
///         // ...
///     }
/// }
///
/// ```
public class DataEntryConfiguration: ObservableObject { // TODO we could strive to remove this? (maybe just make it internal)
    /// The `AccountServiceConfiguration` of the ``AccountService`` for which we currently perform data entry.
    public let serviceConfiguration: AccountServiceConfiguration
    /// The `FocusState` of the parent view.
    /// Focus state is typically handled automatically using the ``AccountKey/focusState`` property.
    /// Access to this property is useful when defining a ``DataEntryView`` that exposes more than one field.
    public let focusedField: FocusState<String?> // see `AccountKey.Type/focusState`


    /// Initializes a new DataEntryConfiguration object.
    /// - Parameters:
    ///   - configuration: The ``AccountServiceConfiguration`` of the ``AccountService`` we currently perform data entry for.
    ///   - focusedField: The `FocusState` of the data entry view.
    init(
        configuration: AccountServiceConfiguration,
        focusedField: FocusState<String?>
    ) {
        self.serviceConfiguration = configuration
        self.focusedField = focusedField
    }
}
