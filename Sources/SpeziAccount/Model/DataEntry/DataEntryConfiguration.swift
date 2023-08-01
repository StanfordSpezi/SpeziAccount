//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A `EnvironmentKey` that stores an instance of ``DataEntryConfiguration`` used exposed by data entry views.
public struct DataEntryConfigurationKey: EnvironmentKey {
    public static var defaultValue: DataEntryConfiguration {
        // TODO log that, something was accessed wrongfully!
        .init(configuration: .init(name: "MOCK"), validationClosures: .init(), focusedField: .init(), viewState: .constant(.idle))
    }
}


/// A `DataEntryConfiguration` provides access configuration state of the parent view of ``DataEntryView``s.
///
/// Data entry views include built-in views like ``SignupForm``. TODO more? maybe rather modeled as a topics section?
/// In subviews like implementations of ``DataEntryView`` you can access the parents views
/// configuration using the `EnvironmentValues/dataEntryConfiguration` environment value.
///
/// ```swift
/// struct SomeDataEntryView: View {
///     @Environment(\.dataEntryConfiguration)
///     var dataEntryConfiguration
///
///     var body: some View {
///         // ...
///     }
/// }
///
/// - Note: Accessing the `DataEntryConfiguration` outside of a data entry parent view
/// ```
public class DataEntryConfiguration {
    /// The `AccountServiceConfiguration` of the ``AccountService`` for which we currently perform data entry.
    public let serviceConfiguration: AccountServiceConfiguration
    /// A control structure that allows you to register data entry validation closures to run input validation
    /// once the submit button is pressed.
    /// For more information see ``DataEntryValidationClosures/register(_:validation:)`` method.
    public let validationClosures: DataEntryValidationClosures
    /// The `FocusState` of the parent view.
    /// Focus state is typically handled automatically using the ``AccountValueKey.Type/focusState`` property.
    /// Access to this property is useful when defining a ``DataEntryView`` that exposes more than one field.
    public let focusedField: FocusState<String?> // see `AccountValueKey.Type/focusState`
    /// Provides access to the Spezi `ViewState` of the parent view.
    public var viewState: Binding<ViewState>


    /// Initializes a new DataEntryConfiguration object.
    /// - Parameters:
    ///   - configuration: The ``AccountServiceConfiguration`` of the ``AccountService`` we currently perform data entry for.
    ///   - validationClosures: The ``DataEntryValidationClosures`` object where subviews can register the submission hooks.
    ///   - focusedField: The `FocusState` of the data entry view.
    ///   - viewState: The Spezi `ViewState` of the data entry view.
    init(
        configuration: AccountServiceConfiguration,
        validationClosures: DataEntryValidationClosures,
        focusedField: FocusState<String?>,
        viewState: Binding<ViewState>
    ) {
        self.serviceConfiguration = configuration
        self.validationClosures = validationClosures
        self.focusedField = focusedField
        self.viewState = viewState
    }
}


extension EnvironmentValues {
    /// Provides access to the ``DataEntryConfiguration`` in the current view environment.
    public var dataEntryConfiguration: DataEntryConfiguration {
        get {
            self[DataEntryConfigurationKey.self]
        }
        set {
            self [DataEntryConfigurationKey.self] = newValue
        }
    }
}
