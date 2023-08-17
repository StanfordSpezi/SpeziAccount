//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A `DataEntryConfiguration` provides access to the configuration state of the parent view of a ``DataEntryView``.
///
/// Data entry views include built-in views like ``SignupForm``.
/// In subviews like implementations of ``DataEntryView`` you can access the parents views
/// configuration using the `@EnvironmentObject` property wrapper.
///
/// ```swift
/// struct SomeDataEntryView: View {
///     @EnvironmentObject
///     var dataEntryConfiguration: DataEntryConfiguration
///
///     var body: some View {
///         // ...
///     }
/// }
///
/// ```
/// - Note: Accessing the `DataEntryConfiguration` outside of a data entry parent view is undefined behavior.
public class DataEntryConfiguration: ObservableObject { // TODO we could strive to remove this?
    /// The `AccountServiceConfiguration` of the ``AccountService`` for which we currently perform data entry.
    public let serviceConfiguration: AccountServiceConfiguration
    /// A control structure that allows you to register data entry validation closures to run input validation
    /// once the submit button is pressed.
    /// For more information see ``DataEntryValidationClosures/register(_:validation:)`` method.
    // TODO public let validationClosures: DataEntryValidationClosures

    /// The `FocusState` of the parent view.
    /// Focus state is typically handled automatically using the ``AccountValueKey/focusState`` property.
    /// Access to this property is useful when defining a ``DataEntryView`` that exposes more than one field.
    public let focusedField: FocusState<String?> // see `AccountValueKey.Type/focusState`
    /// Provides access to the Spezi `ViewState` of the parent view.
    public var viewState: Binding<ViewState>

    // TODO make it possible for the view to detect in which kind of subview it is placed: signup vs overview!


    /// Initializes a new DataEntryConfiguration object.
    /// - Parameters:
    ///   - configuration: The ``AccountServiceConfiguration`` of the ``AccountService`` we currently perform data entry for.
    ///   - closures: The ``DataEntryValidationClosures`` object where subviews can register the submission hooks.
    ///   - focusedField: The `FocusState` of the data entry view.
    ///   - viewState: The Spezi `ViewState` of the data entry view.
    init(
        configuration: AccountServiceConfiguration,
        // TODO closures: DataEntryValidationClosures,
        focusedField: FocusState<String?>,
        viewState: Binding<ViewState>
    ) {
        self.serviceConfiguration = configuration
        // TODO self.validationClosures = closures
        self.focusedField = focusedField
        self.viewState = viewState
    }
}
